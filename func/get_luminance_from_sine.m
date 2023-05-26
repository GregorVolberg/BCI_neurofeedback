function [lum] = get_luminance_from_sine(f, t, phi0)
   lum = (sin(2*pi*f*t+phi0) +1)/2;
  end