
#include <stdio.h>
#include <stdlib.h>

#define Bool   unsigned char
#define True   1
#define False  0

/*--
  IntNative is your platform's `native' int size.
  Only here to avoid probs with 64-bit platforms.
--*/
#define IntNative int


/*--
   change to 1, or compile with -DDEBUG=1 to debug
--*/
#ifndef DEBUG
#define DEBUG 0
#endif

#define NORETURN
#define INLINE

#define FILE int

#define Int32   int
#define UInt32  unsigned int
#define Char    char
#define UChar   unsigned char
#define Int16   short
#define UInt16  unsigned short

#define PATH_SEP    '/'
#define MY_LSTAT    lstat
#define MY_S_IFREG  S_ISREG
#define MY_STAT     stat



UInt32  bytesIn, bytesOut;
Int32   verbosity;
Bool    keepInputFiles, smallMode, testFailsExist;
UInt32  globalCrc;
Int32   numFileNames, numFilesProcessed;


/*-- source modes; F==file, I==stdin, O==stdout --*/
#define SM_I2O           1
#define SM_F2O           2
#define SM_F2F           3

/*-- operation modes --*/
#define OM_Z             1
#define OM_UNZ           2
#define OM_TEST          3

Int32   opMode;
Int32   srcMode;


Int32   longestFileName;
Char    inName[1024];
Char    outName[1024];
Char    *progName;
Char    progNameReally[1024];
FILE    *outputHandleJustInCase;

void    panic                 ( Char* )          NORETURN;
void    ioError               ( void )           NORETURN;
void    compressOutOfMemory   ( Int32, Int32 )   NORETURN;
void    uncompressOutOfMemory ( Int32, Int32 )   NORETURN;
void    blockOverrun          ( void )           NORETURN;
void    badBlockHeader        ( void )           NORETURN;
void    badBGLengths          ( void )           NORETURN;
void    crcError              ( UInt32, UInt32 ) NORETURN;
void    bitStreamEOF          ( void )           NORETURN;
void    cleanUpAndFail        ( Int32 )          NORETURN;
void    compressedStreamEOF   ( void )           NORETURN;

void*   myMalloc ( Int32 );


#define NUM_OVERSHOOT_BYTES 20

UChar    *block;    /*-- compress   --*/
UInt16   *quadrant; /*-- compress   --*/
Int32    *zptr;     /*-- compress   --*/ 
UInt16   *szptr;    /*-- overlays zptr ---*/
Int32    *ftab;     /*-- compress   --*/

UInt16   *ll16;     /*-- small decompress --*/
UChar    *ll4;      /*-- small decompress --*/

Int32    *tt;       /*-- fast decompress  --*/
UChar    *ll8;      /*-- fast decompress  --*/


/*--
  freq table collected to save a pass over the data
  during decompression.
--*/
Int32   unzftab[256];


/*--
   index of the last char in the block, so
   the block size == last + 1.
--*/
Int32  last;


/*--
  index in zptr[] of original string after sorting.
--*/
Int32  origPtr;


/*--
  always: in the range 0 .. 9.
  The current block size is 100000 * this number.
--*/
Int32  blockSize100k;


/*--
  Used when sorting.  If too many long comparisons
  happen, we stop sorting, randomise the block 
  slightly, and try again.
--*/

Int32  workFactor;
Int32  workDone;
Int32  workLimit;
Bool   blockRandomised;
Bool   firstAttempt;
Int32  nBlocksRandomised;



/*---------------------------------------------------*/
/*--- Data decls for the back end                 ---*/
/*---------------------------------------------------*/

#define MAX_ALPHA_SIZE 258
#define MAX_CODE_LEN    23

#define RUNA 0
#define RUNB 1

#define N_GROUPS 6
#define G_SIZE   50
#define N_ITERS  4

#define MAX_SELECTORS (2 + (900000 / G_SIZE))

Bool  inUse[256];
Int32 nInUse;

UChar seqToUnseq[256];
UChar unseqToSeq[256];

UChar selector   [MAX_SELECTORS];
UChar selectorMtf[MAX_SELECTORS];

Int32 nMTF;

Int32 mtfFreq[MAX_ALPHA_SIZE];

UChar len  [N_GROUPS][MAX_ALPHA_SIZE];

/*-- decompress only --*/
Int32 limit  [N_GROUPS][MAX_ALPHA_SIZE];
Int32 base   [N_GROUPS][MAX_ALPHA_SIZE];
Int32 perm   [N_GROUPS][MAX_ALPHA_SIZE];
Int32 minLens[N_GROUPS];

/*-- compress only --*/
Int32  code [N_GROUPS][MAX_ALPHA_SIZE];
Int32  rfreq[N_GROUPS][MAX_ALPHA_SIZE];


/*---------------------------------------------------*/
/*--- 32-bit CRC grunge                           ---*/
/*---------------------------------------------------*/

/*--
  I think this is an implementation of the AUTODIN-II,
  Ethernet & FDDI 32-bit CRC standard.  Vaguely derived
  from code by Rob Warnock, in Section 51 of the
  comp.compression FAQ.
--*/

UInt32 crc32Table[256] = {

   /*-- Ugly, innit? --*/

   0x00000000UL, 0x04c11db7UL, 0x09823b6eUL, 0x0d4326d9UL,
   0x130476dcUL, 0x17c56b6bUL, 0x1a864db2UL, 0x1e475005UL,
   0x2608edb8UL, 0x22c9f00fUL, 0x2f8ad6d6UL, 0x2b4bcb61UL,
   0x350c9b64UL, 0x31cd86d3UL, 0x3c8ea00aUL, 0x384fbdbdUL,
   0x4c11db70UL, 0x48d0c6c7UL, 0x4593e01eUL, 0x4152fda9UL,
   0x5f15adacUL, 0x5bd4b01bUL, 0x569796c2UL, 0x52568b75UL,
   0x6a1936c8UL, 0x6ed82b7fUL, 0x639b0da6UL, 0x675a1011UL,
   0x791d4014UL, 0x7ddc5da3UL, 0x709f7b7aUL, 0x745e66cdUL,
   0x9823b6e0UL, 0x9ce2ab57UL, 0x91a18d8eUL, 0x95609039UL,
   0x8b27c03cUL, 0x8fe6dd8bUL, 0x82a5fb52UL, 0x8664e6e5UL,
   0xbe2b5b58UL, 0xbaea46efUL, 0xb7a96036UL, 0xb3687d81UL,
   0xad2f2d84UL, 0xa9ee3033UL, 0xa4ad16eaUL, 0xa06c0b5dUL,
   0xd4326d90UL, 0xd0f37027UL, 0xddb056feUL, 0xd9714b49UL,
   0xc7361b4cUL, 0xc3f706fbUL, 0xceb42022UL, 0xca753d95UL,
   0xf23a8028UL, 0xf6fb9d9fUL, 0xfbb8bb46UL, 0xff79a6f1UL,
   0xe13ef6f4UL, 0xe5ffeb43UL, 0xe8bccd9aUL, 0xec7dd02dUL,
   0x34867077UL, 0x30476dc0UL, 0x3d044b19UL, 0x39c556aeUL,
   0x278206abUL, 0x23431b1cUL, 0x2e003dc5UL, 0x2ac12072UL,
   0x128e9dcfUL, 0x164f8078UL, 0x1b0ca6a1UL, 0x1fcdbb16UL,
   0x018aeb13UL, 0x054bf6a4UL, 0x0808d07dUL, 0x0cc9cdcaUL,
   0x7897ab07UL, 0x7c56b6b0UL, 0x71159069UL, 0x75d48ddeUL,
   0x6b93dddbUL, 0x6f52c06cUL, 0x6211e6b5UL, 0x66d0fb02UL,
   0x5e9f46bfUL, 0x5a5e5b08UL, 0x571d7dd1UL, 0x53dc6066UL,
   0x4d9b3063UL, 0x495a2dd4UL, 0x44190b0dUL, 0x40d816baUL,
   0xaca5c697UL, 0xa864db20UL, 0xa527fdf9UL, 0xa1e6e04eUL,
   0xbfa1b04bUL, 0xbb60adfcUL, 0xb6238b25UL, 0xb2e29692UL,
   0x8aad2b2fUL, 0x8e6c3698UL, 0x832f1041UL, 0x87ee0df6UL,
   0x99a95df3UL, 0x9d684044UL, 0x902b669dUL, 0x94ea7b2aUL,
   0xe0b41de7UL, 0xe4750050UL, 0xe9362689UL, 0xedf73b3eUL,
   0xf3b06b3bUL, 0xf771768cUL, 0xfa325055UL, 0xfef34de2UL,
   0xc6bcf05fUL, 0xc27dede8UL, 0xcf3ecb31UL, 0xcbffd686UL,
   0xd5b88683UL, 0xd1799b34UL, 0xdc3abdedUL, 0xd8fba05aUL,
   0x690ce0eeUL, 0x6dcdfd59UL, 0x608edb80UL, 0x644fc637UL,
   0x7a089632UL, 0x7ec98b85UL, 0x738aad5cUL, 0x774bb0ebUL,
   0x4f040d56UL, 0x4bc510e1UL, 0x46863638UL, 0x42472b8fUL,
   0x5c007b8aUL, 0x58c1663dUL, 0x558240e4UL, 0x51435d53UL,
   0x251d3b9eUL, 0x21dc2629UL, 0x2c9f00f0UL, 0x285e1d47UL,
   0x36194d42UL, 0x32d850f5UL, 0x3f9b762cUL, 0x3b5a6b9bUL,
   0x0315d626UL, 0x07d4cb91UL, 0x0a97ed48UL, 0x0e56f0ffUL,
   0x1011a0faUL, 0x14d0bd4dUL, 0x19939b94UL, 0x1d528623UL,
   0xf12f560eUL, 0xf5ee4bb9UL, 0xf8ad6d60UL, 0xfc6c70d7UL,
   0xe22b20d2UL, 0xe6ea3d65UL, 0xeba91bbcUL, 0xef68060bUL,
   0xd727bbb6UL, 0xd3e6a601UL, 0xdea580d8UL, 0xda649d6fUL,
   0xc423cd6aUL, 0xc0e2d0ddUL, 0xcda1f604UL, 0xc960ebb3UL,
   0xbd3e8d7eUL, 0xb9ff90c9UL, 0xb4bcb610UL, 0xb07daba7UL,
   0xae3afba2UL, 0xaafbe615UL, 0xa7b8c0ccUL, 0xa379dd7bUL,
   0x9b3660c6UL, 0x9ff77d71UL, 0x92b45ba8UL, 0x9675461fUL,
   0x8832161aUL, 0x8cf30badUL, 0x81b02d74UL, 0x857130c3UL,
   0x5d8a9099UL, 0x594b8d2eUL, 0x5408abf7UL, 0x50c9b640UL,
   0x4e8ee645UL, 0x4a4ffbf2UL, 0x470cdd2bUL, 0x43cdc09cUL,
   0x7b827d21UL, 0x7f436096UL, 0x7200464fUL, 0x76c15bf8UL,
   0x68860bfdUL, 0x6c47164aUL, 0x61043093UL, 0x65c52d24UL,
   0x119b4be9UL, 0x155a565eUL, 0x18197087UL, 0x1cd86d30UL,
   0x029f3d35UL, 0x065e2082UL, 0x0b1d065bUL, 0x0fdc1becUL,
   0x3793a651UL, 0x3352bbe6UL, 0x3e119d3fUL, 0x3ad08088UL,
   0x2497d08dUL, 0x2056cd3aUL, 0x2d15ebe3UL, 0x29d4f654UL,
   0xc5a92679UL, 0xc1683bceUL, 0xcc2b1d17UL, 0xc8ea00a0UL,
   0xd6ad50a5UL, 0xd26c4d12UL, 0xdf2f6bcbUL, 0xdbee767cUL,
   0xe3a1cbc1UL, 0xe760d676UL, 0xea23f0afUL, 0xeee2ed18UL,
   0xf0a5bd1dUL, 0xf464a0aaUL, 0xf9278673UL, 0xfde69bc4UL,
   0x89b8fd09UL, 0x8d79e0beUL, 0x803ac667UL, 0x84fbdbd0UL,
   0x9abc8bd5UL, 0x9e7d9662UL, 0x933eb0bbUL, 0x97ffad0cUL,
   0xafb010b1UL, 0xab710d06UL, 0xa6322bdfUL, 0xa2f33668UL,
   0xbcb4666dUL, 0xb8757bdaUL, 0xb5365d03UL, 0xb1f740b4UL
};


/*---------------------------------------------*/
void initialiseCRC ( void )
{
   globalCrc = 0xffffffffUL;
}


/*---------------------------------------------*/
UInt32 getFinalCRC ( void )
{
   return ~globalCrc;
}


/*---------------------------------------------*/
UInt32 getGlobalCRC ( void )
{
   return globalCrc;
}


/*---------------------------------------------*/
void setGlobalCRC ( UInt32 newCrc )
{
   globalCrc = newCrc;
}


/*---------------------------------------------*/
#define UPDATE_CRC(crcVar,cha)              \
{                                           \
   crcVar = (crcVar << 8) ^                 \
            crc32Table[(crcVar >> 24) ^     \
                       ((UChar)cha)];       \
}


/*---------------------------------------------------*/
/*--- Bit stream I/O                              ---*/
/*---------------------------------------------------*/


UInt32 bsBuff;
Int32  bsLive;
FILE*  bsStream;
Bool   bsWriting;


/*---------------------------------------------*/
void bsSetStream ( FILE* f, Bool wr )
{
   if (bsStream != NULL) panic ( "bsSetStream" );
   bsStream = f;
   bsLive = 0;
   bsBuff = 0;
   bytesOut = 0;
   bytesIn = 0;
   bsWriting = wr;
}


/*---------------------------------------------*/
void bsFinishedWithStream ( void )
{
   if (bsWriting)
      while (bsLive > 0) {
         fputc ( (UChar)(bsBuff >> 24), bsStream );
         bsBuff <<= 8;
         bsLive -= 8;
         bytesOut++;
      }
   bsStream = NULL;
}


/*---------------------------------------------*/
#define bsNEEDR(nz)                           \
{                                             \
   while (bsLive < nz) {                      \
      Int32 zzi = fgetc ( bsStream );         \
      if (zzi == EOF) compressedStreamEOF();  \
      bsBuff = (bsBuff << 8) | (zzi & 0xffL); \
      bsLive += 8;                            \
   }                                          \
}


/*---------------------------------------------*/
#define bsNEEDW(nz)                           \
{                                             \
   while (bsLive >= 8) {                      \
      fputc ( (UChar)(bsBuff >> 24),          \
               bsStream );                    \
      bsBuff <<= 8;                           \
      bsLive -= 8;                            \
      bytesOut++;                             \
   }                                          \
}


/*---------------------------------------------*/
#define bsR1(vz)                              \
{                                             \
   bsNEEDR(1);                                \
   vz = (bsBuff >> (bsLive-1)) & 1;           \
   bsLive--;                                  \
}


/*---------------------------------------------*/
INLINE UInt32 bsR ( Int32 n )
{
   UInt32 v;
   bsNEEDR ( n );
   v = (bsBuff >> (bsLive-n)) & ((1 << n)-1);
   bsLive -= n;
   return v;
}


/*---------------------------------------------*/
INLINE void bsW ( Int32 n, UInt32 v )
{
   bsNEEDW ( n );
   bsBuff |= (v << (32 - bsLive - n));
   bsLive += n;
}


/*---------------------------------------------*/
UChar bsGetUChar ( void )
{
   return (UChar)bsR(8);
}


/*---------------------------------------------*/
void bsPutUChar ( UChar c )
{
   bsW(8, (UInt32)c );
}


/*---------------------------------------------*/
Int32 bsGetUInt32 ( void )
{
   UInt32 u;
   u = 0;
   u = (u << 8) | bsR(8);
   u = (u << 8) | bsR(8);
   u = (u << 8) | bsR(8);
   u = (u << 8) | bsR(8);
   return u;
}


/*---------------------------------------------*/
UInt32 bsGetIntVS ( UInt32 numBits )
{
   return (UInt32)bsR(numBits);
}


/*---------------------------------------------*/
UInt32 bsGetInt32 ( void )
{
   return (Int32)bsGetUInt32();
}


/*---------------------------------------------*/
void bsPutUInt32 ( UInt32 u )
{
   bsW ( 8, (u >> 24) & 0xffL );
   bsW ( 8, (u >> 16) & 0xffL );
   bsW ( 8, (u >>  8) & 0xffL );
   bsW ( 8,  u        & 0xffL );
}


/*---------------------------------------------*/
void bsPutInt32 ( Int32 c )
{
   bsPutUInt32 ( (UInt32)c );
}


/*---------------------------------------------*/
void bsPutIntVS ( Int32 numBits, UInt32 c )
{
   bsW ( numBits, c );
}


/*---------------------------------------------------*/
/*--- Huffman coding low-level stuff              ---*/
/*---------------------------------------------------*/

#define WEIGHTOF(zz0)  ((zz0) & 0xffffff00)
#define DEPTHOF(zz1)   ((zz1) & 0x000000ff)
#define MYMAX(zz2,zz3) ((zz2) > (zz3) ? (zz2) : (zz3))

#define ADDWEIGHTS(zw1,zw2)                           \
   (WEIGHTOF(zw1)+WEIGHTOF(zw2)) |                    \
   (1 + MYMAX(DEPTHOF(zw1),DEPTHOF(zw2)))

#define UPHEAP(z)                                     \
{                                                     \
   Int32 zz, tmp;                                     \
   zz = z; tmp = heap[zz];                            \
   while (weight[tmp] < weight[heap[zz >> 1]]) {      \
      heap[zz] = heap[zz >> 1];                       \
      zz >>= 1;                                       \
   }                                                  \
   heap[zz] = tmp;                                    \
}

#define DOWNHEAP(z)                                   \
{                                                     \
   Int32 zz, yy, tmp;                                 \
   zz = z; tmp = heap[zz];                            \
   while (True) {                                     \
      yy = zz << 1;                                   \
      if (yy > nHeap) break;                          \
      if (yy < nHeap &&                               \
          weight[heap[yy+1]] < weight[heap[yy]])      \
         yy++;                                        \
      if (weight[tmp] < weight[heap[yy]]) break;      \
      heap[zz] = heap[yy];                            \
      zz = yy;                                        \
   }                                                  \
   heap[zz] = tmp;                                    \
}


/*---------------------------------------------*/
void hbMakeCodeLengths ( UChar *len, 
                         Int32 *freq,
                         Int32 alphaSize,
                         Int32 maxLen )
{
   /*--
      Nodes and heap entries run from 1.  Entry 0
      for both the heap and nodes is a sentinel.
   --*/
   Int32 nNodes, nHeap, n1, n2, i, j, k;
   Bool  tooLong;

   Int32 heap   [ MAX_ALPHA_SIZE + 2 ];
   Int32 weight [ MAX_ALPHA_SIZE * 2 ];
   Int32 parent [ MAX_ALPHA_SIZE * 2 ]; 

   for (i = 0; i < alphaSize; i++)
      weight[i+1] = (freq[i] == 0 ? 1 : freq[i]) << 8;

   while (True) {

      nNodes = alphaSize;
      nHeap = 0;

      heap[0] = 0;
      weight[0] = 0;
      parent[0] = -2;

      for (i = 1; i <= alphaSize; i++) {
         parent[i] = -1;
         nHeap++;
         heap[nHeap] = i;
         UPHEAP(nHeap);
      }
      if (!(nHeap < (MAX_ALPHA_SIZE+2))) 
         panic ( "hbMakeCodeLengths(1)" );
   
      while (nHeap > 1) {
         n1 = heap[1]; heap[1] = heap[nHeap]; nHeap--; DOWNHEAP(1);
         n2 = heap[1]; heap[1] = heap[nHeap]; nHeap--; DOWNHEAP(1);
         nNodes++;
         parent[n1] = parent[n2] = nNodes;
         weight[nNodes] = ADDWEIGHTS(weight[n1], weight[n2]);
         parent[nNodes] = -1;
         nHeap++;
         heap[nHeap] = nNodes;
         UPHEAP(nHeap);
      }
      if (!(nNodes < (MAX_ALPHA_SIZE * 2)))
         panic ( "hbMakeCodeLengths(2)" );

      tooLong = False;
      for (i = 1; i <= alphaSize; i++) {
         j = 0;
         k = i;
         while (parent[k] >= 0) { k = parent[k]; j++; }
         len[i-1] = j;
         if (j > maxLen) tooLong = True;
      }
      
      if (! tooLong) break;

      for (i = 1; i < alphaSize; i++) {
         j = weight[i] >> 8;
         j = 1 + (j / 2);
         weight[i] = j << 8;
      }
   }
}


/*---------------------------------------------*/
void hbAssignCodes ( Int32 *code,
                     UChar *length,
                     Int32 minLen,
                     Int32 maxLen,
                     Int32 alphaSize )
{
   Int32 n, vec, i;

   vec = 0;
   for (n = minLen; n <= maxLen; n++) {
      for (i = 0; i < alphaSize; i++)
         if (length[i] == n) { code[i] = vec; vec++; };
      vec <<= 1;
   }
}


/*---------------------------------------------*/
void hbCreateDecodeTables ( Int32 *limit,
                            Int32 *base,
                            Int32 *perm,
                            UChar *length,
                            Int32 minLen,
                            Int32 maxLen,
                            Int32 alphaSize )
{
   Int32 pp, i, j, vec;

   pp = 0;
   for (i = minLen; i <= maxLen; i++)
      for (j = 0; j < alphaSize; j++)
         if (length[j] == i) { perm[pp] = j; pp++; };

   for (i = 0; i < MAX_CODE_LEN; i++) base[i] = 0;
   for (i = 0; i < alphaSize; i++) base[length[i]+1]++;

   for (i = 1; i < MAX_CODE_LEN; i++) base[i] += base[i-1];

   for (i = 0; i < MAX_CODE_LEN; i++) limit[i] = 0;
   vec = 0;

   for (i = minLen; i <= maxLen; i++) {
      vec += (base[i+1] - base[i]);
      limit[i] = vec-1;
      vec <<= 1;
   }
   for (i = minLen + 1; i <= maxLen; i++)
      base[i] = ((limit[i-1] + 1) << 1) - base[i];
}



/*---------------------------------------------------*/
/*--- Undoing the reversible transformation       ---*/
/*---------------------------------------------------*/

/*---------------------------------------------*/
#define SET_LL4(i,n)                                          \
   { if (((i) & 0x1) == 0)                                    \
        ll4[(i) >> 1] = (ll4[(i) >> 1] & 0xf0) | (n); else    \
        ll4[(i) >> 1] = (ll4[(i) >> 1] & 0x0f) | ((n) << 4);  \
   }

#define GET_LL4(i)                             \
    (((UInt32)(ll4[(i) >> 1])) >> (((i) << 2) & 0x4) & 0xF)

#define SET_LL(i,n)                       \
   { ll16[i] = (UInt16)(n & 0x0000ffff);  \
     SET_LL4(i, n >> 16);                 \
   }

#define GET_LL(i) \
   (((UInt32)ll16[i]) | (GET_LL4(i) << 16))


/*---------------------------------------------*/
/*--
  Manage memory for compression/decompression.
  When compressing, a single block size applies to
  all files processed, and that's set when the
  program starts.  But when decompressing, each file
  processed could have been compressed with a
  different block size, so we may have to free
  and reallocate on a per-file basis.

  A call with argument of zero means
  `free up everything.'  And a value of zero for
  blockSize100k means no memory is currently allocated.
--*/


/*---------------------------------------------*/
void allocateCompressStructures ( void )
{
   Int32 n  = 100000 * blockSize100k;
   block    = malloc ( (n + 1 + NUM_OVERSHOOT_BYTES) * sizeof(UChar) );
   quadrant = malloc ( (n     + NUM_OVERSHOOT_BYTES) * sizeof(Int16) );
   zptr     = malloc ( n                             * sizeof(Int32) );
   ftab     = malloc ( 65537                         * sizeof(Int32) );

   if (block == NULL || quadrant == NULL ||
       zptr == NULL  || ftab == NULL) {
      Int32 totalDraw
         = (n + 1 + NUM_OVERSHOOT_BYTES) * sizeof(UChar) +
           (n     + NUM_OVERSHOOT_BYTES) * sizeof(Int16) +
           n                             * sizeof(Int32) +
           65537                         * sizeof(Int32);

      compressOutOfMemory ( totalDraw, n );
   }

   /*--
      Since we want valid indexes for block of
      -1 to n + NUM_OVERSHOOT_BYTES - 1
      inclusive.
   --*/
   block++;

   /*--
      The back end needs a place to store the MTF values
      whilst it calculates the coding tables.  We could
      put them in the zptr array.  However, these values
      will fit in a short, so we overlay szptr at the 
      start of zptr, in the hope of reducing the number
      of cache misses induced by the multiple traversals
      of the MTF values when calculating coding tables.
      Seems to improve compression speed by about 1%.
   --*/
   szptr = (UInt16*)zptr;
}


/*---------------------------------------------*/
void setDecompressStructureSizes ( Int32 newSize100k )
{
   if (! (0 <= newSize100k   && newSize100k   <= 9 &&
          0 <= blockSize100k && blockSize100k <= 9))
      panic ( "setDecompressStructureSizes" );

   if (newSize100k == blockSize100k) return;

   blockSize100k = newSize100k;

   if (ll16  != NULL) free ( ll16  );
   if (ll4   != NULL) free ( ll4   );
   if (ll8   != NULL) free ( ll8   );
   if (tt    != NULL) free ( tt    );

   if (newSize100k == 0) return;

   if (smallMode) {

      Int32 n = 100000 * newSize100k;
      ll16    = malloc ( n * sizeof(UInt16) );
      ll4     = malloc ( ((n+1) >> 1) * sizeof(UChar) );

      if (ll4 == NULL || ll16 == NULL) {
         Int32 totalDraw
            = n * sizeof(Int16) + ((n+1) >> 1) * sizeof(UChar);
         uncompressOutOfMemory ( totalDraw, n );
      }

   } else {

      Int32 n = 100000 * newSize100k;
      ll8     = malloc ( n * sizeof(UChar) );
      tt      = malloc ( n * sizeof(Int32) );

      if (ll8 == NULL || tt == NULL) {
         Int32 totalDraw
            = n * sizeof(UChar) + n * sizeof(UInt32);
         uncompressOutOfMemory ( totalDraw, n );
      }

   }
}
