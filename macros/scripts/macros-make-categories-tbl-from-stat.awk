#!/uns/bin/gawk
function pct(x) { 
  if (usepct) { return (100*x/totLine) + 0.05 } else {return x} 
}

BEGIN {
#Null
  null_define=17;

#Literal
  constant=4;
  literal=12;
  some_constant=19;
    
#Expressions
  expression=7;
  expression_with_assignment=8;
  expression_with_free_variables=9;
  macro_as_function=13;

#Statement
  assembly_code=2;
  statement=20;

#Syntax
  expands_to_reserved_word=5;
  mismatched_entities=15;
  syntax_tokens=22;

#Stringization and Pasting
  stringization=21;
  token_pasting=23;

#Fail
  being_categorized=3;
  failed_categorization=10;
  uncategorized=24;
  multiply_categorized=16;

#Type
  expands_to_type=6;
  has_type_argument=11;
  macro_as_type=14;
  uses_type_argument=25;

#Recursive
  recursive=18;

  if (usepct) { OFMT="%2.1f" } 
  if (nolatex) { OFS="\t"; } 
  else { OFS=" & "; 
  ORS="\\\\\\hline\n"; 
  print "\\begin{tabular}{|l|c|c|c|c|c|c|c|}\\hline"; } 
  print " ",        "Null",   " ",         " ",           " ",          "Stringization", "Other syntatic","Type",   " ",         "Failed"; 
  print "Package", "Define", "Constant", "Expression", "Statement", "and pasting",   "macros",        "Related","Recursive","classification"; } 


/^CATEGORIES_NI:/ {
  cNull = $null_define; sNull += cNull; 
  cLit = $constant + $literal + $some_constant; sLit += cLit; 
  cExp = $expression + $expression_with_assignment + $expression_with_free_variables; sExp += cExp; 
  cStm = $assembly_code + $statement; sStm += cStm; 
  cStrPast = $stringization + $token_pasting; sStrPast += cStrPast; 
  cSyntax = $expands_to_reserved_word + $mismatched_entities + $syntax_tokens; sSyntax += cSyntax; 
  cType = $expands_to_type + $has_type_argument + $macro_as_type + $uses_type_argument; sType += cType; 
  cRecursive = $recursive; sRecursive += cRecursive; 
  cFail = $being_categorized + $failed_categorization + $multiply_categorized; sFail += cFail; # $uncategorized here means its a builtin, don't count
  totLine = cNull + cLit + cExp + cStm + cStrPast + cSyntax + cType + cRecursive + cFail;

  # Create the row heading
  gsub(/\..*$/, "", FILENAME); 

  print FILENAME, pct(cNull), pct(cLit), pct(cExp), pct(cStm), pct(cStrPast), pct(cSyntax), pct(cType), pct(cRecursive), pct(cFail); 
  totLine = 0; 
} 


END { 
  if (!nolatex) { print "\\hline" }; 
  totLine = sNull + sLit + sExp + sStm + sStrPast + sSyntax + sType + sRecursive + sFail;
  print "Total", pct(sNull), pct(sLit), pct(sExp), pct(sStm), pct(sStrPast), pct(sSyntax), pct(sType), pct(sRecursive), pct(sFail); 
  ORS=""; 
  if (!nolatex) {print "\\end{tabular}"; } 
}
