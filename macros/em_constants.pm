#!/uns/bin/perl -w

package em_constants;
require 5.000;
require Exporter;
@ISA = qw(Exporter);
# Initially used below line to generate the @EXPORT line
#perl -ne 'BEGIN {print "\@EXPORT = qw("; } END {print ");\n";} print "$1 " if /([$%@]\w+)\s+/'
@EXPORT = qw($true $false $OBSOLETE $DANGER $EVIL $ILLEGAL
 $catNOTYET $catINPROCESS $catNODEF $catMULTIPLE $catNULLDEFINE 
 $catEXP $catEXPASSIGN $catEXPFREE $catLITERAL $catCONSTANT $catSOMECONSTANT
 $catFAILURE $catHASTYPEARG $catMACROFUN $catMACROTYPE $catUSESTYPEARG
 $catASM $catSYNTAX $catTYPE $catRESDWORD $catSTATEMENT $catRECURSIVE 
 $catMISMATCH $catPASTING $catSTRINGIZE
 @categoryname 
 $typeFAIL $typeBOOL $typeCHAR $typeUCHAR $typeSCHAR $typeSHORT 
 $typeUSHORT $typeINT $typeUINT $typeLONG $typeULONG 
 $typeFLOAT $typeDOUBLE $typeLDOUBLE 
 $typeSTRING $typeNUMBER $typeUNKNOWN $typeUNSPECIFIED $typeNODEF
 %type_num @type_name_array 
 $c_ftype
 @ftype_ALL
 %InclusionMethod_to_Index 
 $ftype_HEADER_Start $ftype_NONHEADER_Start 
 @ftype_CODE @ftype_HEAD @ftype_NOT_INCLUDED @ftype_INCLUDED 
 @ftype_NONHEADER_NOT_INCLUDED @ftype_NONHEADER_INCLUDED 
 @ftype_HEADER_NOT_INCLUDED @ftype_HEADER_INCLUDED 
 $built_in_fake_file 
 $i_usage_code $i_usage_macro $i_usage_cond 
 @i_usage_all
 $ccatDEBUG $ccatPORT_LANLIB $ccatPORT_FEATURE $ccatPORT_MACHINE 
 $ccatCOMMENTING $ccatMI_PREVENTION
 $ccatREDEF_SUPPRESION $ccatMISC_SYSTEM
#End of @EXPORT
);

###########################################################################
### Constants
###

### Boolean
$true = (1 == 1);
$false = (1 == 0);

#use Boolean;  # probably need to add TRUE FALSE to the export list, too
# Boolean uses constant.pm to basically do this:
# sub name TRUE () { 1==1 }
# sub name FALSE () { 1==0 }
# In Perl 5.004, this allegedly will be expanded inline

# some evilness (pasting, stringization) is independent of the others,
# though it may not be able to be classified (actually, stringization
# is pretty easy to classify, when we see that a macro argument follows #).
# In this case evilness is more need-for-preprocessor.

# Also note that some evilness has to do with whole files, or parsing,
# while other has to do with macros that have to be macros.
# Maybe rename the latter from "evil" to "macrofeature" or some such.

# These should probably be merged into failure categories, below
$OBSOLETE = 1;
$DANGER = 2;
$EVIL = 3;
$ILLEGAL = 4;

# Nonconstant: free var (var, function, etc), expression w/side effect,
#	inconsistent types, etc.
# Statement (??)
# Other unclassifiable: give evilness reason, or name the free var,
#	or do multiple of these.


# Categories

# These speak of the BODY; whether the macro takes args is a different matter.
# Right now I return "some constant" many places that I should really return "some value".
# Fix later.

$catNOTYET = 0;		# shouldn't be used; should be undefined instead
$catINPROCESS = 1;
$catNODEF = 2;
$catMULTIPLE = 3;
$catNULLDEFINE = 4;
# Expressions
$catEXP = 5;
$catEXPASSIGN = 6;
$catEXPFREE = 7;		# expression with free variables
$catLITERAL = 8;		# also specify the literal value
$catCONSTANT = 9;		# need to also specify the particular value, if possible
$catSOMECONSTANT = 10;	# a constant, but not known which (e.g., multiple #defines)
# Non-expressions
$catFAILURE = 11;		# shouldn't have just one, should have many
$catHASTYPEARG = 12;		# macro argument has a type
# These shouldn't be failures
$catMACROFUN = 13;
$catMACROTYPE = 14;
$catUSESTYPEARG = 15;

# New categories -- higher numbers take precedence over lower ones
# Be sure to keep in sync w/ strings of @categoryname
$catASM = 16;
$catSYNTAX = 17;		# this goes along with MISMATCH, sort of
$catTYPE = 18;
$catRESDWORD  = 19;
$catSTATEMENT = 20;  # STATEMENT-s likely contain reserved words, but are more specific
$catRECURSIVE = 21;
$catMISMATCH  = 22;
$catPASTING   = 23;
$catSTRINGIZE = 24;


@categoryname = (
		    'uncategorized', 'being_categorized', 'never_defined',
		    'multiply_categorized', 'null_define',
		    'expression', 'expression_with_assignment',
		    'expression_with_free_variables',
		    'literal', 'constant', 'some_constant',
		    'failed_categorization', 'has_type_argument',
		    'macro_as_function', 'macro_as_type',
                    'uses_type_argument',
		    'assembly_code', 'syntax_tokens',
		    'expands_to_type', 'expands_to_reserved_word',
		    'statement',
                    'recursive',
		    'mismatched_entities',
		    'token_pasting',
		    'stringization',
		   );

# Conditional Categories (for #if.* preprocessor directives)
@cond_category_name = qw(debug portability_language_or_library portability_feature
			 portability_machine commenting mi_prevention redef_suppression
			 misc_system);

# T
(
$ccatDEBUG, 
$ccatPORT_LANLIB,
$ccatPORT_FEATURE,
$ccatPORT_MACHINE,
$ccatCOMMENTING,
$ccatMI_PREVENTION,
$ccatREDEF_SUPPRESION,
$ccatMISC_SYSTEM,
 ) = (0..$#cond_category_name-1);

###########################################################################
### Types
###

# Perhaps reserve 0 for unrecognized (non-built-in) type.
# No, with new scheme it's important that it be 0
$typeFAIL = 0;			# does not parse as a valid type
$typeBOOL = 1;
$typeCHAR = 2;			# ought to have typeWCHAR as well
$typeUCHAR = 3;
$typeSCHAR = 4;
$typeSHORT = 5;
$typeUSHORT = 6;
$typeINT = 7;
$typeUINT = 8;
$typeLONG = 9;
$typeULONG = 10;
$typeFLOAT = 11;
$typeDOUBLE = 12;
$typeLDOUBLE = 13;
$typeSTRING = 14;
$typeNUMBER = 15;
$typeUNKNOWN = 16;		# we know it's some type, but don't know which
$typeUNSPECIFIED = 17;		# declared w/o a type (e.g., as function arg)
$typeNODEF = 18;		# no definition (symbol inferred to be macro)

%type_num = ('short' => $typeSHORT, 'short int' => $typeSHORT,
		'signed short' => $typeSHORT, 'signed short int' => $typeSHORT,
		'unsigned short' => $typeUSHORT, 'unsigned short int' => $typeUSHORT,
		'int' => $typeINT, 'signed int' => $typeINT, 'signed' => $typeINT,
		'unsigned int' => $typeUINT, 'unsigned' => $typeUINT,
		'long' => $typeLONG, 'long int' => $typeLONG,
		'signed long' => $typeLONG, 'signed long int' => $typeLONG,
		'unsigned long' => $typeULONG, 'unsigned long int' => $typeULONG,
		'char' => $typeCHAR,
		'unsigned char' => $typeUCHAR,
		'signed char' => $typeSCHAR,
		'float' => $typeFLOAT,
		'double' => $typeDOUBLE,
		'long double' => $typeLDOUBLE,
		'char *' => $typeSTRING, 'char*' => $typeSTRING);

@type_name_array = ('typeFAIL', 'bool',
		    'char', 'unsigned char', 'signed char',
		    'short', 'unsigned short',
		    'int', 'unsigned int',
		    'long', 'unsigned long',
		    'float', 'double', 'long double',
		    'char *',
		    'typeNUMBER',
		    'typeUNKNOWN',
		    'typeUNSPECIFIED',
		    'typeNODEFINITION'
		    );


## Five different kinds of line counts that we care about are:
# (physical,ncnb_phys,cpp_phys,cpp_phys_ncnb)
# We care about these five line counts, %cppcmdcount, $cpp_cmds
# in each of the 8 possible kinds of file-types
# Dimension 1: header file vs code file (use regexp-s)
# Dimension 2: method of inclusion: (input,arg,#include<>,#include"")
#              Maybe only care about first 2 kinds vs. last 2 kinds.
#	       Currently the former are distinguished because we can do
#              so easily, and it might come in handy some day, to generate
#              separate statistics for arbitrary subset of files.
# Note: #include"" or <> is only our filetype if the file was included
# from another file we parsed and it was not given as an input/arg file.
# Generalize the variables for each of these to be lists of eight values.

# This enumeration gives indices into the lists

# 2 (1st dim) times 4 (2nd dim) file types
$c_ftype = 2 * 4;

@ftype_ALL = (0..$c_ftype-1);

($ftype_HEADER_INPUT, $ftype_HEADER_ARG, $ftype_HEADER_INCB, $ftype_HEADER_INCQ,
    $ftype_NONHEADER_INPUT, $ftype_NONHEADER_ARG, $ftype_NONHEADER_INCB, $ftype_NONHEADER_INCQ) = @ftype_ALL;

%InclusionMethod_to_Index =
  ("FromCmdLine" => $ftype_HEADER_ARG,
   "FromStdin" => $ftype_HEADER_INPUT,
   "FromInclude<>" => $ftype_HEADER_INCB,
   "FromInclude\"\"" => $ftype_HEADER_INCQ);

$ftype_HEADER_Start = $ftype_HEADER_INPUT;
$ftype_NONHEADER_Start = $ftype_NONHEADER_INPUT;

# make slices for common uses
@ftype_CODE = ($ftype_HEADER_INPUT..$ftype_HEADER_INCQ);
@ftype_HEAD = ($ftype_NONHEADER_INPUT..$ftype_NONHEADER_INCQ);
@ftype_NOT_INCLUDED = ($ftype_HEADER_INPUT,$ftype_HEADER_ARG,$ftype_NONHEADER_INPUT,$ftype_NONHEADER_ARG);
@ftype_INCLUDED = ($ftype_HEADER_INCB,$ftype_HEADER_INCQ,$ftype_NONHEADER_INCB,$ftype_NONHEADER_INCQ);
@ftype_NONHEADER_NOT_INCLUDED = ($ftype_NONHEADER_INPUT,$ftype_NONHEADER_ARG);
@ftype_NONHEADER_INCLUDED = ($ftype_NONHEADER_INCB,$ftype_NONHEADER_INCQ);
@ftype_HEADER_NOT_INCLUDED = ($ftype_HEADER_INPUT,$ftype_HEADER_ARG);
@ftype_HEADER_INCLUDED = ($ftype_HEADER_INCB,$ftype_HEADER_INCQ);

# Highly unlikely filename, used for $mdef_file[$i] for builtin macros
$built_in_fake_file = "%Built In%";

# enumeration for the macros_uses indices
@i_usage_all = ($i_usage_code, $i_usage_macro, $i_usage_cond) = (0..2);



1; #Successful import
__END__
