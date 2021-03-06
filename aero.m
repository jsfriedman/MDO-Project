function [L, D] = aero(A_root, A_tip, c_root, c_tip, lambda_1, lambda_2, J,...
    theta_root, theta_kink, theta_tip, W_fuel_c, W_wing_c)
    %% Aerodynamic solver setting

    [KinkCST,Xt_r,Xl_r,Xt_k,Xl_k,Xt_t,Xl_t,Xt_85,Xl_85] = AFinterp(A_root,A_tip,J);
    global kink;
    kink.CST = KinkCST;
    kink.x_root_upper= Xt_r;
    kink.x_root_lower = Xl_r;
    kink.x_kink_upper = Xt_k;
    kink.x_kink_lower = Xl_k;
    kink.x_tip_upper = Xt_t;
    kink.x_tip_lower = Xl_t;
    kink.x85_upper = Xt_85;
    kink.x85_lower = Xl_85;
    
    x_kink = 10.36/tand(90-lambda_1);
    x_tip = x_kink + (J-10.36)/(tand(90-lambda_2));
    c_kink = c_root - x_kink + 0.02;
    % Wing planform geometry 
    %                x    y     z   chord(m)    twist angle (deg) 
    AC.Wing.Geom = [0, 0, 0, c_root, theta_root;
                    x_kink, 10.36, 0, c_kink, theta_kink;
                    x_tip, J, 0, c_tip, theta_tip];

    % Wing incidence angle (degree)
    AC.Wing.inc  = 0;   


    % Airfoil coefficients input matrix
    %                    | ->     upper curve coeff.                <-|   | ->       lower curve coeff.       <-| 
    AC.Wing.Airfoils   = [A_root(1), A_root(2), A_root(3), A_root(4), A_root(5), A_root(6),...
                          A_root(7), A_root(8), A_root(9), A_root(10), A_root(11), A_root(1);
                          KinkCST(1),KinkCST(2), KinkCST(3), KinkCST(4), KinkCST(5), KinkCST(6),...
                          KinkCST(7), KinkCST(8), KinkCST(9), KinkCST(10), KinkCST(11), KinkCST(12);
                          A_tip(1), A_tip(2), A_tip(3), A_tip(4), A_tip(5), A_tip(6),...
                          A_tip(7), A_tip(8), A_tip(9), A_tip(10), A_tip(11), A_tip(12)];

    kink_location = 10.36/J;
    AC.Wing.eta = [0;kink_location;1];  % Spanwise location of the airfoil sections

    % Viscous vs inviscid
    AC.Visc  = 1;              % 0 for inviscid and 1 for viscous analysis

    % Flight Condition
    AC.Aero.V     = 244.377;            % flight speed (m/s)
    AC.Aero.rho   = 0.4397;         % air density  (kg/m3)
    AC.Aero.alt   = 9500;             % flight altitude (m)
    tr = (c_tip/c_root);
    MAC = (2/3) * c_root*(1+tr+tr^2)/(1+tr);
    mu = 1.475e-5;
    AC.Aero.Re    = (AC.Aero.rho * AC.Aero.V * MAC)/(mu);        % reynolds number (bqased on mean aerodynamic chord)
    AC.Aero.M     = 0.81;           % flight Mach number
    qc = 0.5*AC.Aero.rho*AC.Aero.V^2;
    S = 2*(0.5*(c_root+c_kink)*10.36 + 0.5*(c_kink+c_tip)*(J-10.36));
    base_weight = 154.44e3;
    WTO_max = W_fuel_c + W_wing_c + base_weight;
    W_design  = sqrt(WTO_max*(WTO_max-W_fuel_c));
    AC.Aero.CL    = (W_design*9.81)/(qc*S);          % lift coefficient - comment this line to run the code for given alpha%
    %AC.Aero.Alpha = 2;             % angle of attack -  comment this line to run the code for given cl 

    Res = Q3D_solver(AC);
    
    L = Res.CLwing*qc*S;
    D = Res.CDwing*qc*S;
end