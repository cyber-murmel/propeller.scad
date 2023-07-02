use <bezier.scad>;

// diameter
d = 160;
// blade angle at hub
a1 = 45; // [0:90]
// blade angle at tip
a2 = 30; // [0:90]
// blade width at hub
w = 20;
// number of blades
n = 3;
// motor shaft diameter
d_shaft = 1.5;
// manufacturing tolerance
tolerance = 0.15;
// brim width
b = 2.4;
// number of fragments
$fn = 90;

// https://nathanrooy.github.io/posts/2016-09-14/airfoil-manipulation-via-bezier-curves-with-python/
control_points=[[1+0.03*cos(a1),0.03*sin(a1)],              // trailing edge (top)
        [0.76,0.08],
        [0.52,0.125],
        [0.25,0.12],
        [0.1,0.08],
        [0,0.03],               // leading edge (top)
        [0,-0.03],              // leading edge (bottom)
        [0.15,-0.08],
        [0.37,-0.01],
        [0.69,0.02],
        [1-0.03*cos(a1),-0.03*sin(a1)]];             // trailing edge (bottom)

start_points = [ for (t=[0:1/$fn:1]) bezier([
  control_points[0],
  control_points[1],
  (control_points[1] + control_points[2])/2
], t)];

mid_points = [ for(i = [1: len(control_points)-3])
  each [ for (t=[0:1/$fn:1]) bezier([
    (control_points[i] + control_points[i+1])/2,
    control_points[i+1],
    (control_points[i+1] + control_points[i+2])/2
  ], t)]
];

end_points = [ for (t=[0:1/$fn:1]) bezier([
  (control_points[len(control_points)-1] + control_points[len(control_points)-2])/2,
  control_points[len(control_points)-2],
  control_points[len(control_points)-1]
], t)];

airfoil_points = concat(start_points, mid_points, end_points);

module blade(r, w, a1, a2) {
  slop_hub = tan(a1);
  slope_tip = tan(a2);
  translate([w*cos(a1)/2, 0])
    rotate([90, 0, 0])
      linear_extrude(r
        ,scale=[1, slope_tip/slop_hub]
      )
        rotate(-a1)
          translate([-w, 0])
            scale(w)
              polygon(airfoil_points);
}

module nose(r=2.5, h=5) {
  rotate_extrude() {
    polygon(concat([
      [0, 0]],
      [ for (t=[0:1/$fn:1]) bezier([
        [r*1.125, 0],
        [r*1.125, 2*h/3],
        [r*1.125, h],
        [0, h]],
    t)]));
  }
}

difference() {
  union() {
    nose(r=w*cos(a1)/2, h=w);

    for(a = [360/n:360/n:360])
      rotate(a)
        blade(r=d/2, w=w, a1=a1, a2=a2);
  }
  translate([0, 0, -1])
    cylinder(d=d_shaft+2*tolerance, h=w*sqrt(1/2)+1);
}


rotate_extrude() {
  polygon([ for (t=[0:1/$fn:1]) bezier([
    [d/2-b/2, 0],
    [d/2, w*sin(a1)*1.25],
    [d/2+b/2, 0]
  ], t)]);
}
