% Jonathan Friedman 4799380
% Jackson Horwitz [INSERT]
% AE4205 MDO for Aerospace, Final Project, 2018Q1

% This is intended to be the main file of the program. This might change as
% we go along.

% Run this file

%% Initial Values (including "guess" variables)
root_upper1 = 0.1739; 
root_upper2 = 0.2814;
root_upper3 = 0.2007;
root_upper4 = 0.3183;
root_upper5 = 0.1761;
root_upper6 = 0.2942;
root_lower1 = -0.1026; 
root_lower2 = -0.1127;
root_lower3 = -0.2200;
root_lower4 = 0.0312;
root_lower5 = -0.0651;
root_lower6 = 0.1376;
tip_upper1 = 0.1146; 
tip_upper2 = 0.1969;
tip_upper3 = 0.1106;
tip_upper4 = 0.2567;
tip_upper5 = 0.1245;
tip_upper6 = 0.2606;
tip_lower1 = -0.0434; 
tip_lower2 = -0.0282;
tip_lower3 = -0.1299;
tip_lower4 = 0.0928;
tip_lower5 = -0.0135;
tip_lower6 = 0.1712;
c_root = 15.5;
c_tip = 3.75;
lambda_1 = 35;
lambda_2 = 35;
J = 25.9;
theta_root = 0;
theta_kink = 0;
theta_tip = 0;

L_c = 2.3077e6;
D_c = 1.4423e5;
ccL_c = false;
cM_c = false;
W_fuel_c = 88677;
W_wing_c = 40606.6;

%% Design Variable
x0 = [root_upper1, root_upper2, root_upper3, root_upper4, root_upper5, root_upper6,...
      root_lower1, root_lower2, root_lower3, root_lower4, root_lower5, root_lower6,...
      tip_upper1, tip_upper2, tip_upper3, tip_upper4, tip_upper5, tip_upper6,...
      tip_lower1, tip_lower2, tip_lower3, tip_lower4, tip_lower5, tip_lower6,...
      c_root, c_tip, lambda_1, lambda_2, J, theta_root, theta_kink, theta_tip,...
      L_c, D_c, ccL_c, cM_c, W_fuel_c, W_wing_c];

%% Bounds
lower_bounds = [0.1462, 0.2420, 0.1586, 0.2896, 0.1520, 0.2786,...
      -0.1302, -0.1521, -0.2621, 0.0025, -0.0892, 0.1220,...
      0.0988, 0.1745, 0.0865, 0.2404, 0.1106, 0.2517,...
      -0.0591, -0.0508, -0.1539, 0.0764, -0.0272, 0.1623,...
      12.4, 2.9, 28, 28, 20, -15,-15, -15, ...
      1846160, 115384, ccL_c, cM_c, 62500, 32e3]; % same order as in the design variable
  
upper_bounds = [0.2015, 0.3209, 0.2427, 0.3471, 0.2001, 0.3099,...
      -0.0750, -0.0732, -0.1780, 0.0600, -0.0410, 0.1533,...
      0.1304, 0.2195, 0.1346, 0.2732, 0.1382, 0.2696,...
      -0.0276, -0.0057, -0.1058, 0.1902, 0.0003, 0.1802,...
      18.6, 4.5, 42, 42, 35, 15,15, 15,...
      2769240, 173076, ccL_c, cM_c, 150e3, 49e3]; % same order as in the design variable

%% Initial Constraint Values


%% Optimization Options
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.DiffMinChange   = 1e-6;         % Minimum change while gradient searching
options.DiffMaxChange   = 5e-2;         % Maximum change while gradient searching
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 1e3;          % Maximum iterations
options.PlotFcns        = {@optimplotfval, @optimplotx, @optimplotfirstorderopt};


%% Global Variables
    % add all of the variables that have "guess" copies as globals. maybe
    % also add all design variables?
global couplings;
couplings.L = L;
couplings.L_c = L_c;
couplings.D = D;
couplings.D_c = D_c;
couplings.W_wing = W_wing;
couplings.W_wing_c = W_wing_c;
couplings.W_fuel = W_fuel;
couplings.W_fuel_c = W_fuel_c;
couplings.ccL = ccL;
couplings.ccL_c = ccL_c;
couplings.cM = cM;
couplings.cM_c = cM_c;

%% fmincon
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@(x) Optim(x),x0,[],[],[],[],lower_bounds,upper_bounds,@(x) constraints(x),options);
