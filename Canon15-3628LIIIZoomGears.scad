
$fn=82*4;       // Smooth cylinders

OuterRadius        = 84.90 / 2; // These are the desired dimensions and may need to be measured and adjusted as above      
InnerRadius        = 80.2                 / 2; // These are the desired dimensions and may need to be measured and adjusted as above      

Height             = 5.0;       // The height of the housings gear ring.
GearHeight         = 8.0;       // The height of the housings gears.
InnerCutoutHeight  = 2.5;       // The cutout dimensions suit 2.62mm OD o-ring material for grip surface.         
InnerCutoutDepth   = 2.4;       // See cutout height above.        
NumberOfTeeth      = 82;        // Copied from a purchased Canon 17-40mm ring gear.
ToothBevelWidth    = 1.0;       // Make gear engagement easier.
GraspRingThickness = 3.35;      // 

// Make corrections and tweaks due to systematic printing errors
OuterCorrection        = 1.005;
InnerCorrection        = 0.9900373599;
CorrectedOuterRadius   = OuterRadius * OuterCorrection;        
CorrectedInnerRadius   = InnerRadius * InnerCorrection;        

union()
{
  // Upper Grasp Ring
  difference()
  {  
    graspRing();
    // Top Grasp Ring Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [1+CorrectedInnerRadius+1.0*GraspRingThickness,Height-GraspRingThickness/2],
        [1+CorrectedInnerRadius+0.5*GraspRingThickness,Height],
        [1+CorrectedInnerRadius+1.0*GraspRingThickness,Height]]
      );
    // bottom Grasp Ring Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [1+CorrectedInnerRadius+1.0*GraspRingThickness,GraspRingThickness/2],
        [1+CorrectedInnerRadius+0.5*GraspRingThickness,0],
        [1+CorrectedInnerRadius+1.0*GraspRingThickness,0]]
      );
  }
  // Gear Ring
  difference()
  {
    //Gear Ring Positioning  
    translate([0,0,Height*1.5])
    {
      gear(m = OuterCorrection, z = NumberOfTeeth, x = 0, h = GearHeight, w = 20, clearance = 0.1, center = true);
    }
    // Gear Ring Lens Clearance     
    cylinder(r = CorrectedInnerRadius, h = 2*GearHeight);
    // Bottom Gear Teeth Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [CorrectedOuterRadius-ToothBevelWidth,1.5*Height+GearHeight/2],
        [CorrectedOuterRadius,1.5*Height+GearHeight/2],
        [CorrectedOuterRadius,1.5*Height+GearHeight/2-ToothBevelWidth]]
      );
  }
}

module graspRing()
difference()
{
  difference()
  {
    cylinder(r = CorrectedInnerRadius+GraspRingThickness,h = Height);
    cylinder(r = CorrectedInnerRadius, h = Height);
  }
  *translate([0,0,(Height-InnerCutoutHeight)/2])
  {
    for (i = [0:120:240])
    {    
      rotate(a = i) rotate_extrude(angle=45,convexity=10)
        square([CorrectedInnerRadius+InnerCutoutDepth,InnerCutoutHeight],false);
    }    
  }  
}  

module gear(m = 1, z = 10, x = 0, h = 4, w = 20, clearance = 0.1, center = true)
{
	linear_extrude(height = h, center = center, convexity = z)
    gear2D(m, z, x, w, clearance); 
}


//==============================================================
// 2D Gear Stuff
// Courtesy of Rudolf Huttary (Parkinbot)
// https://www.thingiverse.com/thing:636119
//==============================================================

iterations = 150; // increase for enhanced resolution beware: large numbers will take lots of time!

// default values
z = 10; // teeth - beware: large numbers may take lots of time!
m = 1;  // modulus
x = 0;  // profile shift
h = 6;  // face_width	respectively axial height
w = 20; // profile angle
clearance = 0.1; // assymmetry of tool to clear tooth head and foot. For internal splines use -.1

module gear2D(m = 1, z = 10, x = 0, w = 20, clearance = 0.1)
{
  	r_wk = m*z/2 + x; 
    U = m*z*PI; 
   	dy = m;  
  	r_fkc = r_wk + dy *(1-clearance/2);  
  s = 360/iterations; 
  difference()
  {
    circle(r_fkc, $fn=300);  // workpiece
    for(i=[0:s:360])
      rotate([0, 0, -i])
      translate([-i/360*U, 0, 0])
      Rack(m, z, x, w, clearance);  // Tool
  }
}

module Rack(m = 1, z = 10, x = 0, w = 20, clearance = 0)
  {
    p = m*PI; 
    dy = 2*m;  
    dx = dy * tan(w);  
    ddx = dx/2 * clearance/2; 
    ddy = dy/2 * clearance/2; 
    r_wk = m*z/2 + x; 
    y0 = r_wk+dy; 
    y1 = r_wk+dy/2-ddy; 
    y2 = r_wk+dy/2 - ddy; 
    y3 = r_wk-dy/2 - ddy; 
    x0 = p/4-dx/2 + ddx; 
    x1 = p/4+dx/2 + ddx; 
    x2 = 3*p/4-dx/2 - ddx; 
    x3 = 3*p/4+dx/2 - ddx; 
    polygon(points = tooth(z));
    
    function tooth(z = 10) = concat([[-p, y0],[-p, y1]],  
		[for(i=[-1:z], j=[0:3]) to(i*p)[j]], [[(z+1)*p, y1], [(z+1)*p, y0]]); 
      
    function to(dx) = [[dx+x0, y2], [dx+x1, y3], [dx+x2, y3], [dx+x3, y2]]; 
}
