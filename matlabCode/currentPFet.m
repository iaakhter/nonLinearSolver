function [I, firDerSrc, firDerGate, firDerDrain, secDerSrc, secDerGate, secDerDrain, secDerSrcGate, secDerSrcDrain, secDerGateDrain] = currentPFet(src, gate, drain, Vtp, Vtn, Vdd, Kn, Sn)
  if(nargin < 8) Sn = 8/3.0; end;
  if(nargin < 7) Kn = 1.5; end;
  if(nargin < 6) Vdd = 1.8; end;
  if(nargin < 5) Vtn = 0.4; end;
  if(nargin < 4) Vtp = -0.4; end;
  Kp = -Kn/2.0;
  Sp = Sn*2.0;

  IpMax = 0.0;
  constantSrc = Vdd;
  constantGate = 0.0;
  constantDrain = 0.0;
  constantGs = constantGate - constantSrc;
  constantDs = constantDrain - constantSrc;

  if constantGs >= Vtp
    IpMax = 0.0;
  elseif constantDs <= constantGs - Vtp
    IpMax =  0.5*Sp*Kp*(constantGs - Vtp)*(constantGs - Vtp);
  elseif constantDs >= constantGs - Vtp
    IpMax = Sp*Kp*(constantGs - Vtp - constantDs/2.0)*constantDs;
  end;
  gp = -IpMax/Vdd;
  
  I = 0.0;
  firDerSrc = 0.0;
  firDerGate = 0.0;
  firDerDrain = 0.0;
  secDerSrc = 0.0;
  secDerGate = 0.0;
  secDerDrain = 0.0;
  secDerSrcGate = 0.0;
  secDerSrcDrain = 0.0;
  secDerGateDrain = 0.0;
  gs = gate - src;
  ds = drain - src;

  IpLeak = ds*(2 - (gs - Vtp)/Vdd)*(gp*1e-4);
  firDerLeakSrc = (gp*1e-4)*((ds)*(1.0/Vdd) - (2 - (gs - Vtp)/Vdd));
  firDerLeakGate = (gp*1e-4)*(-ds/Vdd);
  firDerLeakDrain = (gp*1e-4)*(2 - (gs - Vtp)/Vdd);
  secDerLeakSrc = (-2*1e-4)*(gp/Vdd);
  secDerLeakGate = 0.0;
  secDerLeakDrain = 0.0;
  secDerLeakSrcGate = (gp*1e-4)*(1/Vdd);
  secDerLeakSrcDrain = (gp*1e-4)*(1/Vdd);
  secDerLeakGateDrain = (gp*1e-4)*(-1/Vdd);
  
  if src < drain
    [I, firDerSrc, firDerGate, firDerDrain, secDerSrc, secDerGate, secDerDrain, secDerSrcGate, secDerSrcDrain, secDerGateDrain] = currentPFet(drain, gate, src, Vtp, Vtn, Vdd, Kn, Sn);
    I = -I;
    firDerSrc = -firDerSrc;
    firDerGate = -firDerGate;
    firDerDrain = -firDerDrain;
    secDerSrc = -secDerSrc;
    secDerGate = -secDerGate;
    secDerDrain = -secDerDrain;
    secDerSrcGate = -secDerSrcGate;
    secDerSrcDrain = -secDerSrcDrain;
    secDerGateDrain = -secDerGateDrain;
  else
    if gs >= Vtp
    	I = 0.0;
      firDerSrc = 0.0;
      firDerGate = 0.0;
      firDerDrain = 0.0;
      secDerSrc = 0.0;
      secDerGate = 0.0;
      secDerDrain = 0.0;
      secDerSrcGate = 0.0;
      secDerSrcDrain = 0.0;
      secDerGateDrain = 0.0;
    elseif (ds <= gs - Vtp)
      I = Sp*(Kp/2.0)*(gs - Vtp)*(gs - Vtp);
      firDerSrc = -Sp*Kp*(gate - src - Vtp);
      firDerGate = Sp*Kp*(gate - src - Vtp);
      firDerDrain = 0.0;
      secDerSrc = Sp*Kp;
      secDerGate = Sp*Kp;
      secDerDrain = 0.0;
      secDerSrcGate = -Sp*Kp;
      secDerSrcDrain = 0.0;
      secDerGateDrain = 0.0;
    elseif (ds >= gs - Vtp)
      I = Sp*(Kp)*(gs - Vtp - ds/2.0)*ds;
      firDerSrc = Sp*Kp*(src - gate + Vtp);
      firDerGate = Sp*Kp*(drain - src);
      firDerDrain = Sp*Kp*(gate - Vtp - drain);
      secDerSrc = Sp*Kp;
      secDerGate = 0.0;
      secDerDrain = -Sp*Kp;
      secDerSrcGate = Sp*Kp;
      secDerSrcDrain = 0.0;
      secDerGateDrain = Sp*Kp;
    end;
    if IpLeak > 0
      disp('Neg INLEAK IN PFET')
      src
      gate
      drain
      IpLeak
      gp
    end;
    I = I + IpLeak;
    firDerSrc = firDerSrc + firDerLeakSrc;
    firDerGate = firDerGate + firDerLeakGate;
    firDerDrain = firDerDrain + firDerLeakDrain;
    secDerSrc = secDerSrc + secDerLeakSrc;
    secDerGate = secDerGate + secDerLeakGate;
    secDerDrain = secDerDrain + secDerLeakDrain;
    secDerSrcGate = secDerSrcGate + secDerLeakSrcGate;
    secDerSrcDrain = secDerSrcDrain + secDerLeakSrcDrain;
    secDerGateDrain = secDerGateDrain + secDerLeakGateDrain;
  end
end % inverter