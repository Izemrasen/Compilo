/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_RULE_TAB_H_INCLUDED
# define YY_YY_RULE_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    tINTEGER = 258,
    tCONSTANT = 259,
    tCHAR = 260,
    tSTRING = 261,
    tNUMBER = 262,
    tID = 263,
    tVOID = 264,
    tIF = 265,
    tELSE = 266,
    tWHILE = 267,
    tFOR = 268,
    tMAIN = 269,
    tRETURN = 270,
    tCOMMA = 271,
    tBEGIN_PARENTHESIS = 272,
    tEND_PARENTHESIS = 273,
    tBEGIN_BLOCK = 274,
    tEND_BLOCK = 275,
    tEND_OF_INSTRUCTION = 276,
    tPRINTF = 277,
    tQUOTE = 278,
    tPLUS = 279,
    tMINUS = 280,
    tMULTIPLY = 281,
    tDIVIDE = 282,
    tASSIGN = 283,
    tGT = 284,
    tGTE = 285,
    tLT = 286,
    tLTE = 287,
    tEQUALITY = 288,
    tTRUC = 289
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 19 "rule.y" /* yacc.c:1909  */

	char *str;
	int nb;

#line 94 "rule.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_RULE_TAB_H_INCLUDED  */
