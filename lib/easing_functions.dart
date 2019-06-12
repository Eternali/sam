class EasingFunctions {

    static double easeInOutCubic(double t) =>
      t<.5 ? 4*t*t*t : (t-1)*(2*t-2)*(2*t-2)+1;

}
