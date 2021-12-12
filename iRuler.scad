// iRuler by DrLex
// Based on customizable ruler by Stu121.
// License: Creative Commons - Attribution - Share Alike
// 2017-04-21: v2: added inches option
// 2021-12-11: v3: added dual units & rounded corners; dropped shrinkage compensation (it makes more sense to always generate 1:1 models and let the user do the scaling in their slicer)

/* [General] */
Units="centimeters"; //[centimeters, inches, both]
// Length of the measuring part. When using 'both' units, this length is in inches.
RulerLength=10; //[1:50]
RulerWidth=35; //[20:1:50]
WithHole="yes"; //[yes, no]
ReverseDesign="no"; //[yes, no]
// If nonzero, round corners with this radius
RoundCorners=0; //[0:.5:5]

/* [Text] */
RulerText="iRuler";
FontSize=10; //[3:.5:14]
BoldFont="no"; //[yes, no]
NarrowFont="no"; //[yes, no]
TextHeight=1; //[-2.6:.1:5]
TextX=3;
TextY=0; //[-10:.5:10]

/* [Numbers] */
NumberSize=7; //[1:15]
BoldNumbers="no"; //[yes, no]
NumberHeight=.5; //[-2.6:.1:5]
NumberOffset=0; //[-2:.5:2]

/* [Ruler lines] */
UnitsLineWidth=.5; //[.3:.05:.7]
SubdivisionsGapWidth=.3; //[.2:.05:.5]

/* [Hidden] */
scaleLength = Units == "centimeters" ? RulerLength*10 : RulerLength*25.4;
rulerLength2 = floor(scaleLength/10);
shift2 = ReverseDesign == "yes" ? 0 : scaleLength - rulerLength2*10;
Font= NarrowFont == "no" ? "Roboto" : "Roboto Condensed";
Font2="Roboto Condensed";
Hole=(WithHole == "yes");
Inverted=(ReverseDesign == "yes");
TextFont = BoldFont == "no" ? Font : str(Font, ":style=Bold");
NumberFont = BoldNumbers == "no" ? Font2 : str(Font2, ":style=Bold");
textCenterY = (Units == "both") ? RulerWidth/2 - 5 : RulerWidth/2 + 3;


module unitLines(unit, length) {
    uSize = unit == "inches" ? 25.4 : 10;
    for (i=[0:1:length]) {
        translate([i*uSize-UnitsLineWidth/2,-4.9,0.6]) rotate([8.5,0,0]) cube([UnitsLineWidth,10,.7]);
    }
}

module subdivisions(unit, length) {
    //Subdivision lines. These are recessed to improve printability with thicker nozzles.
    if(unit == "centimeters") {
        for (i=[1:length*10]) {
            if(i % 10) {
                GapLength=(i % 5) ? 5 : 6.5;
                translate([i-SubdivisionsGapWidth/2,-4.95,0.5]) rotate([8.5,0,0]) cube([SubdivisionsGapWidth,GapLength,.7]);
            }
        }
    }
    else {
        for (i=[0:length-1]) {
            translate([(i+0.5)*25.4-SubdivisionsGapWidth/2,-4.95,0.5]) rotate([8.5,0,0]) cube([SubdivisionsGapWidth,8,.7]);
            for (j=[0:1]) {
                translate([(i+0.25+j*0.5)*25.4-SubdivisionsGapWidth/2,-4.95,0.5]) rotate([8.5,0,0]) cube([SubdivisionsGapWidth,6,.7]);
            }
            for (j=[0:3]) {
                translate([(i+0.125+j*0.25)*25.4-SubdivisionsGapWidth/2,-4.95,0.5]) rotate([8.5,0,0]) cube([SubdivisionsGapWidth,4.25,.7]);
            }
            for (j=[0:7]) {
                translate([(i+0.0625+j*0.125)*25.4-SubdivisionsGapWidth/2,-4.95,0.5]) rotate([8.5,0,0]) cube([SubdivisionsGapWidth,2.5,.7]);
            }
        }
    }
}

module numbers(unit, length, reverse) {
    uSize = unit == "inches" ? 25.4 : 10;
    Thickness=abs(NumberHeight) + (NumberHeight < 0 ? 0.1 : 0);
    ZPos=NumberHeight >= 0 ? 2.5 : 2.5+NumberHeight;
    Rot=reverse ? [0,0,180] : [0,0,0];
    RotCenter=[length*uSize/2, 5.5+NumberSize/2, 0];
    translate(RotCenter) rotate(Rot) {
        for (i=[1:1:length]) {
            //NumberOffsetActual=(i > 9) ? NumberOffset-2.5 : NumberOffset;
            translate([(i*uSize)+NumberOffset,5.5,ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
                text(str(i),NumberSize,font=NumberFont,halign="center",$fn=24);
        }
        unitText = unit == "inches" ? "IN" : "CM";
        translate([0,5.5,ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
            text(unitText,5,font=NumberFont,halign="center",$fn=24);
    }
}

module label() {
    Thickness=abs(TextHeight) + (TextHeight < 0 ? 0.1 : 0);
    ZPos=TextHeight >= 0 ? 2.5 : 2.5+TextHeight;
    Rot=Inverted ? [0,0,180] : [0,0,0];
    RotCenter=[scaleLength/2+5,TextY,0];
    translate(RotCenter) rotate(Rot) {
        translate([TextX,TextY,ZPos]-RotCenter) linear_extrude(Thickness, convexity=6)
            text(RulerText,FontSize,font=TextFont,valign="center",$fn=24);
    }
}

intersection() {
difference() {
    union() {
        top_width = RulerWidth - (Units == "both" ? 20 : 10);
        hull() {
            translate([0,5,0])   cube([scaleLength+10,top_width,2.5]);
            translate([0,-5,0])  cube([scaleLength+10,RulerWidth,1]);
        }

        translate([5,0,0]) {
            if(Units != "both") {
                unitLines(Units, RulerLength);
                if(NumberHeight > 0) {
                    numbers(Units, RulerLength, Inverted);
                }
            }
            else {
                unitLines("inches", RulerLength);
                if(NumberHeight > 0) {
                    numbers("inches", RulerLength, Inverted);
                }
                rotate([0,0,180]) translate([-scaleLength+shift2,-RulerWidth+10,0]) {
                    unitLines("centimeters", rulerLength2);
                    if(NumberHeight > 0) {
                        numbers("centimeters", rulerLength2, !Inverted);
                    }
                }
            }
        }
        
        if (TextHeight > 0 && RulerText != "") {
            translate([0,textCenterY,0]) label();
        }
    }

    translate([5,0,0]) {
        if(Units != "both") {
            subdivisions(Units, RulerLength);
            if (NumberHeight < 0) {
                numbers(Units, RulerLength, Inverted);
            }
        }
        else {
            subdivisions("inches", RulerLength);
            if (NumberHeight < 0) {
                numbers("inches", RulerLength, false);
            }
            rotate([0,0,180]) translate([-scaleLength+shift2,-RulerWidth+10,0]) {
                subdivisions("centimeters", rulerLength2);
                if (NumberHeight < 0) {
                    numbers("centimeters", rulerLength2, !Inverted);
                }
            }
        }
    }

    if (TextHeight < 0 && RulerText != "") {
        translate([0,textCenterY,0]) label();
    }
    if (Hole) {
        holeX = Inverted ? 10 : scaleLength;
        holeY = (Units == "both") ? RulerWidth/2 - 5 : 18;
        translate([holeX,holeY,2])  cylinder(10, 2.5, 2.5, center=true, $fn=16);
    }
}

if(RoundCorners > 0) {
    hull() {
        translate([RoundCorners,-5+RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=16);
        translate([RoundCorners,RulerWidth-5-RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=24);
        translate([scaleLength+10-RoundCorners,-5+RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=24);
        translate([scaleLength+10-RoundCorners,RulerWidth-5-RoundCorners,0]) cylinder(h=20, r=RoundCorners, center=true, $fn=16);

    }
}
}