function [lum] = get_luminance_from_sine_new(f, t, phi0, pattern, lumVec)
lum = (sin(2*pi*f*t+phi0) +1)/2;
   
   if pattern > 1
       lum = sin(2*pi*f*t+phi0)
       0.5
       lum = round(lum);
   end
   lum * lumVec
end
  abs(sign(sin(2*1.2*5.4*1+0)) + lumVec)