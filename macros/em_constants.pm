#!/uns/bin/perl -w

package em_constants;
require 5.000;
require Exporter;
@ISA = qw(Exporter);
# Initially used below line to generate the @EXPORT line
#perl -ne 'BEGIN {print "\@EXPORT = qw("; } END {print ");\n";} print "$1 " if /([$%@]\w+)\s+/'
@EXPORT = qw(
 $true $false $OBSOLETE $DANGER $EVIL $ILLEGAL

 $catNOT_YET $catIN_PROCESS $catNO_DEF $catNULL_DEFINE $catEXP
 $catSOME_CONSTANT $catCONSTANT $catLITERAL
 $catSTATEMENT $catSTATEMENT_SANS_SEMI $catPARTIAL_STATEMENT
 $catSTATEMENTS $catSTATEMENTS_SANS_SEMI $catPARTIAL_STATEMENTS
 $catTYPE $catPARTIAL_TYPE $catDECLARATION $catDECLARATION_SANS_SEMI
 $catRESERVED_WORD $catFUNCTION_NAME $catSYMBOL_UNKNOWN $catSYMBOLS
 $catRECURSIVE
 $catUNBALANCED $catPUNCTUATION $catCOMMAND_LINE $catASSEMBLY_CODE
 $catMULTIPLE $catFAILURE $catLast @categoryname

 $propNONE $propASSIGN $propFREE_VAR $propINVOKES_MACRO
 $propPASSES_TYPE_AS_ARG $propUSES_MACRO_AS_TYPE $propUSES_ARG_AS_TYPE
 $propASSEMBLY_CODE $propPASTING $propSTRINGIZE

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
 @cond_category_name
 $ccatDEBUG $ccatPORT_LANLIB $ccatPORT_LANMACRO $ccatPORT_SYSMACRO
 $ccatPORT_FEATURE $ccatPORT_MACHINE
 $ccatCOMMENTING $ccatMI_PREVENTION
 $ccatREDEF_SUPPRESION $ccatMISC_SYSTEM $ccatOTHER $ccatMIXED

 $c_reserved_type_word_alternatives $c_reserved_nontype_word_alternatives
 $c_plus_plus_reserved_type_word_alternatives
 $c_plus_plus_reserved_nontype_word_alternatives $reserved_type_word_re
 $reserved_nontype_word_re $reserved_word_re

 $constant_exp_re $constant_or_upcase_exp_re $float_literal_whole_re
 $float_literal_frac_re $float_literal_exp_re $float_literal_noexp_re
 $hex_literal_re $dec_oct_literal_re $number_literal_re
 $char_literal_contents_re $char_literal_re $non_escaped_double_quote_re
 $string_literal_re

 $identifier_no_dollar_re $identifier_re $type_specifier_re $type_special
 $type_re_special_1 $type_re_special_2 $type_re_special $type_suffix_re
 $type_re $type_qualifier_re $pointer_declarator_prefix_re
 $pointer_declarator_prefixes_re $array_declarator_suffix_re
 $array_declarator_suffixes_re $declarator_unparenthesized_re
 $declarator_parenthesized_re $declarator_re $type_declarator_re
 $simple_arglist_re $type_declarator_arglist_re $numeric_type_word_re
 $numeric_type_re $non_numeric_type_re $builtin_type_base_re
 $builtin_type_re $numeric_binop_regexp $bool_binop_regexp
 $arb_type_binop_regexp $binop_regexp $prefix_unop_regexp
 $postfix_unop_regexp $selector_regexp
 $cpp_include_arg_re
);
#End of @EXPORT


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

# These should probably be merged into failure categories, below
$OBSOLETE = 1;
$DANGER = 2;
$EVIL = 3;
$ILLEGAL = 4;


###########################################################################
### Categories
###

# These speak of the BODY; whether the macro takes args is a different matter.
# Add "varargs" as a category?  Also other failures?

## Failure:
$catNOT_YET = 0;		# shouldn't be used; should be undefined instead
$catIN_PROCESS = 1;		# currently being categorized
$catNO_DEF = 2;			# can happen if a macro expands to (name of)
				#   another macro that is never defined

## Null define:
$catNULL_DEFINE = 3;

## Expression:
$catEXP = 4;
$catSOME_CONSTANT = 5;	# a constant, but not known which (e.g., multiple #defines)
$catCONSTANT = 6;		# need to also specify the particular value
$catLITERAL = 7;		# also specify the literal value

## Statement
$catSTATEMENT = 8;
$catSTATEMENT_SANS_SEMI = 9;	# semicolon-less statement
$catPARTIAL_STATEMENT = 10;
# Are these useful, or should they be a property?
$catSTATEMENTS = 11;		# multiple statements
$catSTATEMENTS_SANS_SEMI = 12;		# multiple statements, last one lacks semicolon
$catPARTIAL_STATEMENTS = 13;	# multiple statements, last one incomplete

## Type
$catTYPE = 14;			# expands to a type
$catPARTIAL_TYPE = 15;

$catDECLARATION = 16;		# add partial_declaration?
$catDECLARATION_SANS_SEMI = 17;

## Single symbol (no $catMACRONAME: if expands to a macro, inherit its type)
$catRESERVED_WORD = 18;		# expands to (just) non-type reserved word -- irrelevant?
$catFUNCTION_NAME = 19;		# expands to name of function declared in package
$catSYMBOL_UNKNOWN = 20;	# symbol (not function, macro, or reserved word)
				#   (probably a macro whose def we didn't see,
				#    or possibly a local or global variable)

$catSYMBOLS = 21;		# multiple space-separated symbols: #def P(x,y) x y
				# (it might actually be a declaration_sans_semi)

$catRECURSIVE = 22;		# not sure there are enough of these to justify;
				# currently all but about 5 are misclassifications

## Fragments
$catUNBALANCED = 23;		# unbalanced parentheses; was $catMISMATCH;
				#   includes {), so perhaps that was better,
				#   but "mismatch" isn't as evocative
$catPUNCTUATION = 24;	# expands to just punctuation token(s); was $catSYNTAX

## Not C code:
$catCOMMAND_LINE = 25;		# Command-line arguments
$catASSEMBLY_CODE = 26;

$catMULTIPLE = 27; # a def gets this if it expands to a macro with this category
$catFAILURE = 28;		# other sorts of failure (for example...?)

$catLast = 28;			# same as last one

@categoryname = (
		 'uncategorized', 'being_categorized', 'never_defined',
		 'null_define',
		 'expression', 'some_constant', 'constant', 'literal',
		 'statement', 'semicolonless_statement', 'partial_statement',
		 'statements', 'semicolonless_statements', 'partial_statements',
		 'type', 'partial_type',
		 'declaration', 'semicolonless_declaration',
		 'reserved_word', 'function_name', 'unknown_symbol',
		 'symbols',
		 'recursive',
		 'mismatched_entities',
		 'punctuation',
		 'command_line_arguments', 'assembly_code',
		 'multiply_categorized',
		 'failed_categorization');

if ((not defined($categoryname[$catLast]))
     || defined($categoryname[$catLast+1]))
{ die "categoryname and catLast out of synch! '$categoryname[$catLast]' '$categoryname[$catLast+1]'"; }

# Properties, which can be attached to any of the above:
$propNONE = 0;
$propASSIGN = 1;
$propFREE_VAR = 2;		# expression with free variables
$propINVOKES_MACRO = 4;	# uses a macro as a function -- irrelevant?
$propPASSES_TYPE_AS_ARG = 8;	# body passes a type to another macro
$propUSES_MACRO_AS_TYPE = 16;	# expands a macro where a type is expected
$propUSES_ARG_AS_TYPE = 32;	# a macro argument was used as a type
$propASSEMBLY_CODE = 64;	# contains in-line assembly code
$propPASTING   = 128;
$propSTRINGIZE = 256;

sub prop_contains ($$)
{ my ($prop, $bit) = checkargs(2, @_);
  return ($prop & $bit); }


# 		 'token_pasting',
# 		 'stringization',
# 		 'has_type_argument',
# 		 'macro_as_function', 'macro_as_type',
# 		 'uses_type_argument',
# 		 'assembly_code', ,




## Old version; delete soon.
# $catNOT_YET = 0;		# shouldn't be used; should be undefined instead
# $catIN_PROCESS = 1;
# $catNO_DEF = 2;
# $catMULTIPLE = 3; # a def gets this if it expands to a macro with this category
# $catNULL_DEFINE = 4;
# # Expressions
# $catEXP = 5;
# $catEXPASSIGN = 6;
# $catEXPFREE = 7;		# expression with free variables
# $catLITERAL = 8;		# also specify the literal value
# $catCONSTANT = 9;		# need to also specify the particular value, if possible
# $catSOME_CONSTANT = 10;	# a constant, but not known which (e.g., multiple #defines)
# # Non-expressions
# $catFAILURE = 11;		# shouldn't have just one, should have many
# $catHASTYPEARG = 12;		# macro argument has a type
# # These shouldn't be failures
# $catMACROFUN = 13;
# $catMACROTYPE = 14;
# $catUSESTYPEARG = 15;
# 
# # New categories -- higher numbers take precedence over lower ones
# # Be sure to keep in sync w/ strings of @categoryname
# $catASM = 16;
# $catSYNTAX = 17;		# this goes along with MISMATCH, sort of
# $catTYPE = 18;			# expands to a type
# $catRESERVED_WORD  = 19;
# $catSTATEMENT = 20;  # STATEMENT-s likely contain reserved words, but are more specific
# $catRECURSIVE = 21;
# $catMISMATCH  = 22;
# $catPASTING   = 23;
# $catSTRINGIZE = 24;
# $catCOMMAND_LINE   = 25;
# 
# $catLast = 25;
# 
# @categoryname = (
# 		 'uncategorized', 'being_categorized', 'never_defined',
# 		 'multiply_categorized', 'null_define',
# 		 'expression', 'expression_with_assignment',
# 		 'expression_with_free_variables',
# 		 'literal', 'constant', 'some_constant',
# 		 'failed_categorization', 'has_type_argument',
# 		 'macro_as_function', 'macro_as_type',
# 		 'uses_type_argument',
# 		 'assembly_code', 'syntax_tokens',
# 		 'expands_to_type', 'expands_to_reserved_word',
# 		 'statement',
# 		 'recursive',
# 		 'mismatched_entities',
# 		 'token_pasting',
# 		 'stringization',
# 		 'command_line_arguments'
# 		 );

# Conditional Categories (for #if.* preprocessor directives)
@cond_category_name = qw(debug portability_language_or_library portability_language_macro
			 portability_system_macro portability_feature
			 portability_machine commenting mi_prevention redef_suppression
			 misc_system other mixed_categories);

# Define an enumeration of the various cond compilation directive categories,
# just use the numbers from 0 on up (is there a less "clever" way to do this?)
(
$ccatDEBUG,
$ccatPORT_LANLIB,
$ccatPORT_LANMACRO,  #e.g. inline
$ccatPORT_SYSMACRO,  #e.g. S_IFIFO, errno
$ccatPORT_FEATURE,
$ccatPORT_MACHINE,
$ccatCOMMENTING,
$ccatMI_PREVENTION,
$ccatREDEF_SUPPRESION,
$ccatMISC_SYSTEM,
$ccatOTHER,
$ccatMIXED,
 ) = (0..$#cond_category_name);


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


###########################################################################
### Regular expressions
###

# Use /o in matches for these, so interpolation/compilation occurs just once.
# Use single, not double, quotes so as not to lose the backslashes.
# But note that \\ and \' are interpolated in single-quoted strings.
# "\b" prevents two words from running up against one another.
# These regexps are intended not to include any leading or trailing space

### Reserved words

# can appear in a type
$c_reserved_type_word_alternatives = 'char|const|double|enum|extern|float|int|long|register|short|signed|static|struct|union|unsigned|void|volatile';
# can't appear in a type
$c_reserved_nontype_word_alternatives = 'asm|auto|break|case|continue|default|do|else|entry|for|fortran|goto|if|return|sizeof|switch|typedef|while';
$c_plus_plus_reserved_type_word_alternatives = 'bool|class|friend|inline|private|protected|public|virtual';
$c_plus_plus_reserved_nontype_word_alternatives = 'asm|catch|const_cast|delete|dynamic_cast|false|mutable|namespace|new|operator|reinterpret_cast|static_cast|template|this|throw|true|try|typeid|using';

$reserved_type_word_re = '\b(' . $c_reserved_type_word_alternatives
  . '|' . $c_plus_plus_reserved_type_word_alternatives . ')\b';
$reserved_nontype_word_re = '\b(' . $c_reserved_nontype_word_alternatives
  . '|' . $c_plus_plus_reserved_nontype_word_alternatives . ')\b';
$reserved_word_re ='\b(' . $c_reserved_type_word_alternatives
  . '|' . $c_plus_plus_reserved_type_word_alternatives
  . '|' . $c_reserved_nontype_word_alternatives
  . '|' . $c_plus_plus_reserved_nontype_word_alternatives . ')\b';


### Literals

# FIX: this regexp is lame-- L,x,U needed for 0x80 << 1LU
# It also matches whitespace and (bad!) the variable x, etc.
$constant_exp_re = '[-lLuUxX0-9() \t<>+=*|&%!]+';
# $like constant_exp_re, but supposed to match macro uses too.
$constant_or_upcase_exp_re = '[-a-zA-Z_lLuUxX0-9() \t<>+=*|&%!]+';

# Numeric literals
# floating-point number (four variants): $1 = exponent, $2 = suffix (fFlL)
$float_literal_whole_re = '[-+]?\d+\.\d*([eE][-+]?\d+)?([fFlL]?)'; # decimal 2.
$float_literal_frac_re = '[-+]?\d*\.\d+([eE][-+]?\d+)?([fFlL]?)'; # fraction .2
$float_literal_exp_re = '[-+]?\d+([eE][-+]?\d+)([fFlL]?)'; # exponent 1e37
$float_literal_noexp_re = '[-+]?\d+()([fF])'; # no exponent 22f
# integer regexp: $1 = number, $2 = suffix (uUlL); permit two L's for GNU extension
$hex_literal_re = '(0[xX][0-9a-fA-F]+)([uUlL]?[uUlL]?[uUlL]?)'; # regexp failed with \d for 0-9
$dec_oct_literal_re = '(\d+)([uUlL]?[uUlL]?[uUlL]?)';
# Using this is probably ill-advised.
$number_literal_re = '((' . join(')|(', $float_literal_whole_re, $float_literal_frac_re, $float_literal_exp_re, $float_literal_noexp_re, $hex_literal_re, $dec_oct_literal_re) . '))';

# Character and string literals
# NOTE: GJB changed the below to {1,3}, but ANSI requires exactly 3 --
# will just evilprint an error.  Changed back to 3
$char_literal_contents_re = '(\\\\?.|\\\\[0-7]{3})';
$char_literal_re = "L?'" . $char_literal_contents_re . "'";
$non_escaped_double_quote_re = '(^|[^\\\\])(\\\\\\\\)*\"';
# non-greedy '.*?' because '.*' matches too much, skips over intervening quotes
$string_literal_re = 'L?\"(|.*?[^\\\\])(\\\\\\\\)*\"'; # string literal

### Types

# Types and declarations/definitions.
# In general, use $identifier_re in preference to "\w+"
$identifier_no_dollar_re = '\b[a-zA-Z_]\w*\b';	# 0 groups
# Fix: $ as first character doesn't work: the leading \b won't match.
$identifier_re = '(?:\b[a-zA-Z_]|\$)[a-zA-Z0-9_\$]*\b';	# 0 groups
$type_specifier_re = $identifier_re . '(?:\s+' . $identifier_re. ')*'; # 0 groups
# Gross special case.  I'm sorry.  [I think this isn't necessary any more.]
# Don't combine with type_re because that is sometimes combined with
# $type_declarator_re, which must match before $type_re but after this.
$type_special = 'int (*)(dc_num, dc_num, int, dc_num *)';
# Can't get \Q, \E to work.
# my $type_re_special = '(?:\Q$type_special\E)';	# 0 groups
# my $type_re_special = "(?:\\Q$type_special\\E)";
$type_re_special_1 = 'int \(\*\)\(dc_num, dc_num, int, dc_num \*\)';
$type_re_special_2 = 'int \(\*\)\(void\)';
$type_re_special = '(?:' . $type_re_special_1 . '|' . $type_re_special_2 . ')';
# contains leading whitespace; unconditional; 0 groups
$type_suffix_re = '(?:\s*(?:\*|\[\s*\]))';
$type_re = $type_specifier_re . $type_suffix_re . '*'; # 0 groups
# Use $type_declarator_re instead.
# $type_identifier_re = $type_re . '\s*' . $identifier_re;

# Declarators are actually rather more complicated than this:  see H&S p. 85.
# We can't really use a regexp to catch them all.  Just hope to catch most...
$type_qualifier_re = '\b(?:const|volatile|register)\b'; # 0 groups
$pointer_declarator_prefix_re = '\*(?:\s*' . $type_qualifier_re . ')*'; # 0 groups
$pointer_declarator_prefixes_re = '(?:' . $pointer_declarator_prefix_re . '\s*)*'; # 0 groups
$array_declarator_suffix_re = '\[(?:' . $constant_or_upcase_exp_re . ')?\]'; # 0 groups
$array_declarator_suffixes_re = '(?:\s*' . $array_declarator_suffix_re . ')*'; # 0 groups
# Don't do this!  Just look for type_declarator followed by open paren.
# $function_declarator_suffix_re = ...;
# declaratorsuffix = $array_declarator_suffix_re plus $function_declarator_suffix_re
$declarator_unparenthesized_re = $pointer_declarator_prefixes_re
  . $identifier_re . $array_declarator_suffixes_re; # 0 groups
$declarator_parenthesized_re = $pointer_declarator_prefixes_re
  . '\(' . $declarator_unparenthesized_re . '\)' . $array_declarator_suffixes_re; # 0 groups
$declarator_re = '(' . $declarator_parenthesized_re . '|'
  . $declarator_unparenthesized_re . ')'; # 1 group: the declarator
# Use this in preference to $type_identifier_re
# 2 groups: $1 = type specifier, $2 = declarator
# my $type_declarator_unparen_re = '(' . $type_specifier_re . ')\s*' . $declarator_re;
# For functions, does NOT include the open paren or any argument info.
$type_declarator_re = '(' . $type_specifier_re . ')\s*' . $declarator_re;
# Should probably use $type_declarator_re and $type_re
$simple_arglist_re = '\(\s*(?:' . $identifier_re . '\s*\**\s*(?:,\s*' . $identifier_re . '\s*\**\s*)*)?\s*\)'; # 0 groups
# 3 groups: $1 = type specifier, $2 = declarator, $3 = arglist
$type_declarator_arglist_re = $type_declarator_re . '\s*(' . $simple_arglist_re . ')';

# # This isn't going to work, because of looping.  Break the loop somehow.
# $simple_declarator_re = $identifier_re;
# $arraydeclarator = $directdeclarator . '\s*\[(' . $constant_exp_re . ')?\]';
# $direct_declarator_re = '(' . $arraydeclarator . '|' . $simple_declarator_re . ')';
# $pointer_declarator_re = '\*(\s*' . $type_qualifier_re . ')*\s*' . $direct_declarator_re;
# $declarator_re = '(' . $pointer_declarator_re . '|' . $direct_declarator_re . ')';
# type plus identifier:  $1 = type, $5 = identifier

# Does not handle function types
$numeric_type_word_re = '\b(short|signed|unsigned|long|int|char|float|double)\b';
$numeric_type_re = $numeric_type_word_re . '(\s+' . $numeric_type_word_re . ')*';
$non_numeric_type_re = '\b(void)\b';
$builtin_type_base_re = "($numeric_type_re|$non_numeric_type_re|" . '\b(struct|union|enum)\s+' . "$identifier_re)";
$builtin_type_re = $builtin_type_base_re . $type_suffix_re . '*';

## Binary operators
# $numeric_binop_regexp should precede $bool_binop_regexp because of < and <<.
# $bool_binop_regexp should precede $numeric_binop_regexp because of | and ||.
# Better yet, get rid of this, go back to one regexp, and have a hashtable to
# give precedences, types, etc.
$numeric_binop_regexp = '<<=?|>>=?|[-*\/%+&^\|]=?';
$bool_binop_regexp = '[<=>!]=|&&|\|\||<|>';
# This might return a boolean, number, or something else.
$arb_type_binop_regexp = '=';
$binop_regexp = '(?:<<=?|>>=?|&&|\|\||[<=>!]=|[-*\/%+&^\|]=?|[<=>])';
$prefix_unop_regexp = '(?:~!-\+&\*|\+\+|--)';
$postfix_unop_regexp = '(?:\+\+|--)';
$selector_regexp = '(?:\.|->)';


# Cpp operators
# Two groups: first for angled include, second for quoted include
$cpp_include_arg_re = '(?:<(.*)>|\"(.*)\")';

1; #Successful import
__END__
