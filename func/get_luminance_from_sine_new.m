function [lum] = get_luminance_from_sine_new(f, t, phi0, pattern)
lum = (sin(2*pi*f*t+phi0) +1)/2;
   limsin = sin(2*pi*f*t+phi0);
%   if pattern > 1
%       lum = round(lum);
%   end
end
  