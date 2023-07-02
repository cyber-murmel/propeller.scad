$fn = 90;

control_points = [[0, 0], [10, 0], [20, 20], [30, 00], [40, 0]];

function line(end_points, t) = end_points[0]+t*(end_points[1]-end_points[0]);

function bezier(control_points, t) = len(control_points) == 2 ? 
    line(control_points, t) :
    bezier([
        for (i = [0: len(control_points)-2])
            bezier([control_points[i], control_points[i+1]], t)
    ], t);

module curve(curve_points, w=1) {
    for (i = [0: len(curve_points)-2]) {
        hull() {
            translate(curve_points[i])
                circle(d=w);
            translate(curve_points[i+1])
                circle(d=w);
        }
    }
}

curve_points = [ for (t=[0:1/$fn:1]) bezier(control_points, t)];

polygon(curve_points);
translate([0, 20])
    curve(curve_points);

#for (point = control_points) {
    translate(point)
        circle(d=1);
}
