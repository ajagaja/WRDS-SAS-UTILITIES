 /*--------------------------------------------------------------*
  *    Name: defined.sas                                         *
  *   Title: Determine if a macro variable is defined            *
        Doc: http://www.datavis.ca/sasmac/defined.html     
  *--------------------------------------------------------------*
  *  Author:  Michael Friendly            <friendly@yorku.ca>    *
  * Created: 17 Feb 2003 10:43:40                                *
  * Revised: 17 Feb 2003 10:43:40                                *
  * Version: 1.0                                                 *
  *                                                              *
  *--------------------------------------------------------------*/
 /*=
=Description:
 
 The DEFINED macro returns a value of 0 (false) if the argument is
 the name of a non-existent macro variable.  It returns a 1 if the
 macro variable exists in the global macro environment.

==Method:

 You can check if a macro variable has been defined by checking the
 dictionary.macro or sashelp.vmacro view.  
 This version was provided in a sas-l posting by David Ward.                  
 
==Parameters:

* MVAR      The name of a macro variable

=Example:

 The DEFINED macro is usually used within other macros, e.g.,

	%global test;
	%let test=3;

	%macro testit;
	%if %defined(test)
		%then put TEST is defined as &test;
		%else put TEST is undefined;
	%mend;

	%testit;


 =*/


%macro defined (mvar);
  %local dsid rc scope;
  	/** Open the vmacro view which contains info about macor vars **/
  %let dsid=%sysfunc(open(sashelp.vmacro (where=(name="%upcase(&mvar)"))));
  	/** Fetch a record into the pdv if it exists **/
  %let rc=%sysfunc(fetch(&dsid));
  	/** Return varnum 1, the scope **/
  %let scope = %sysfunc(getvarc(&dsid,1));
  	/** Close the view **/
  %let rc=%sysfunc(close(&dsid));
  %if &scope = GLOBAL %then 1; %else 0;
%mend;

