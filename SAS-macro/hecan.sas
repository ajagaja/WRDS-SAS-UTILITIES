 /*--------------------------------------------------------------*
  *    Name: hecan.sas                                           *
  *   Title: Canonical discriminant HE plots                     *
        Doc: http://www.datavis.ca/sasmac/hecan.html       
  *--------------------------------------------------------------*
  *  Author:  Michael Friendly            <friendly@yorku.ca>    *
  * Created: 21 Nov 2006 12:08:36                                *
  * Revised: 27 May 2007 14:48:27                                *
  * Version: 1.2-0                                              *
  * 1.1  Added XEXTRA=, YEXTRA=  to pass to CANPLOT              *
  *      Passed VAXIS, HAXIS to CANPLOT                          *
  * 1.2 Switched from using %heplot to %heplots                  *
  * - Added VARCOLOR= to set the color for variable vectors/labels *
  *                                                              *
  *--------------------------------------------------------------*/
 /*=
=Description:
 
 The HECAN macro produces a canonical HE plot for one factor effect in
 a multivariate linear model (MANOVA).  This is a plot of the between-
 and within-class variation projected in the space that maximally
 discrimnates among groups. The plot is similar to that produced by the
 L<CANPLOT macro|canplot.html>, except that group means are represented
 by an H ellipse and error variation is shown explicitly as an E ellipse
 (which plots as a circle in canonical space).  The variable vectors
 in this space show the correlations of the variables with each of the
 canonical (discriminant) dimensions.

==Method:

 The HECAN macro uses the CANPLOT macro to find the coordinates of group means
 and variable vectors in canonical space, followed by the L<HEPLOT macro|heplot.html>
 of the canonical variables to produce the HE plot.

=Usage:

 The HECAN macro is defined with keyword parameters.
 The arguments may be listed within parentheses in any order, separated
 by commas. For example: 
 
	%hecan(data=soils, var=pH--Conduc, class=Gp);
 
==Parameters:

* DATA=       The name of the input data set [Default: DATA=_LAST_]

* VAR=        The names of two or more variables to be analyzed.  This may be given as
              a blank-separated list or a SAS abbreviation, e.g., X1-X10, educ--density.

* CLASS=      List of class/factor variables

* COLORS=     Colors for the class variable levels

* INC=        X, Y axis increments, passed to CANPLOT

* XEXTRA=     # of extra X axis tick marks on the left and right.  Use this to
              extend the axis range. [Default: XEXTRA=0 0]

* YEXTRA=     # of extra Y axis tick marks on the bottom and top. [Default: YEXTRA=0 0]

* VECSCALE=   Scale factor for variable vectors in CANPLOT.  If VECSCALE=AUTO (the
              default), the scale factor is calculated from the ratio of ranges of
			  the variable vectors to observation points. [Default: VECSCALE=AUTO]

* ANNOADD=    Additional annotations for HEPLOT

* CANX=       Horizontal axis of plot [Default: CANX=CAN1]

* CANY=       Vertical axis of plot [Default: CANY=CAN2]

* LEGEND=     Legend statement for HEPLOT [Default: LEGEND=NONE]

* VAXIS=      Name of an axis statement for the y variable.  If you specify VAXIS=AXIS98,
              the program uses an equated axis statement generated by the CANPLOT macro

* HAXIS=      Name of an axis statement for the x variable.  If you specify HAXIS=AXIS99,
              the program uses an equated axis statement generated by the CANPLOT macro


* CIRCLES=    Draw the confidence circles for the canonical means? [Default: CIRCLES=NO]

* CAPLOT=     Draw the plot produced by CANPLOT? [Default: CAPLOT=NO]
                
=References:

 Friendly, M. (2006).
   Data Ellipses, HE Plots and Reduced-Rank Displays for Multivariate Linear 
   Models: SAS Software and Examples. 
   I<Journal of Statistical Software>, 17(6), 1-42.
   L<http://www.jstatsoft.org/v17/i06/>

 Friendly, M. (2007).
   HE plots for Multivariate General Linear Models.
   I<Journal of Computational and Graphical Statistics>, 16, in press.
   L<http://www.datavis.ca/papers/heplots.pdf>


 =*/

%macro hecan(
	data=_last_,
	var=,           /* list of response variables                                 */
	class=,         /* list of class/factor variables                             */
	colors=,        /* colors for the class variable levels                       */
	inc=,           /* X, Y axis increments, passed to CANPLOT                    */
	xextra=0 0,   /* # of extra x axis tick marks              */
	yextra=0 0,   /* # of extra y axis tick marks              */
	vecscale=AUTO,  /* scale factor for variable vectors in CANPLOT               */
	annoadd=,       /* additional annotations for HEPLOT                          */
	canx=can1,      /* Horizontal axis of plot                                    */
	cany=can2,      /* Vertical axis of plot                                      */
	size=evidence,  /* how to scale H ellipse(s) relative to E      */
	alpha=0.05,     /* signif level for Roy test, if size=evidence  */
	level=0.68,     /* coverage proportion for E ellipse            */
	legend=,        /* legend statement for HEPLOT                                */
	vaxis=,         /* name of an axis statement for the y variable               */
	haxis=,         /* name of an axis statement for the x variable               */
	varcolor=,      /* color for variable vectors and labels     */
	circles=no,     /* to suppress the confidence circles for the canonical means */
	caplot=no,      /* to suppress the plot produced by CANPLOT                   */
	name=hecan
	);

%local me; %let me = HECAN;
%let circles=%upcase(&circles);

%*-- Check for required parameters;
%local abort;
%let abort=0;
%if %length(&var)=0 %then %do;
	%put ERROR: (&me) The VAR= variables must be specified;
	%let abort=1;
	%goto done;
	%end;

%if %length(&class)=0 %then %do;
	%put ERROR: (&me) The CLASS= variable(s) must be specified;
	%let abort=1;
	%goto done;
	%end;

%canplot(data=&data,  class=&class,
   var=&var,  
   inc=&inc, 
   xextra=&xextra,
   yextra=&yextra,
   haxis=&haxis,
   vaxis=&vaxis,
   scale=&vecscale, 
   colors=&colors,
   varcolor=&varcolor,
   annoadd=mean,
   legend=none,
   out=_scores_,
   anno=_cananno_,
   plot=&caplot
   );

%*-- if axis statements were generated by EQUATE, use them;
%if %length(&vaxis)=0 and %length(&haxis)=0 %then %do;
	%let vaxis=axis98;
	%let haxis=axis99;
	%end;
 
*-- Remove conf. circles?;
%if &circles = NO %then %do;
data _cananno_;
   set _cananno_;
   where comment not in ('CIRCLE');
   run;
	%end;

*-- Cannonical HE plot for the Contour*Depth interaction;
proc glm data=_scores_ outstat=_canstats_ noprint;
   class &class;
   model &canx &cany = &class / nouni ss3;
   manova h=&class;
run; quit;

*options mprint;
%heplots(data=_scores_, stat=_canstats_,
   x=&canx, y=&cany,
   effect=&class,
   legend=&legend,
   vaxis=&vaxis, haxis=&haxis,
   anno=_cananno_ &annoadd,
   size=&size, alpha=&alpha, level=&level,
   name=&name
	);

%done:
%mend;
