%% Collision‑Avoidance Constellation Helianthus Simulation 
% Full Visualization & Analysis: Walker Delta Phasing, Earth, Orbits,
% Sampled Satellites, Closest‑Pair Labels, Violin & KDE Plots with Legend
clc;                       % Clear the command window
clear;                     % Remove all variables from workspace
close all;                 % Close all figure windows

%% 1) ORBIT & PHASING PARAMETERS
Re             = 6371e3;  % Earth radius in meters
hp             = 200e3;   % Perigee altitude above Earth in meters
ha             = 2000e3;  % Apogee altitude above Earth in meters
N_planes       = 30;      % Number of orbital planes
sats_per_plane = 360;     % Number of satellites per plane
F              = 4;       % Walker Δ phasing parameter
inc            = deg2rad(53); % Orbit inclination converted to radians

%% 2) LABELING: Planes A… and Satellites A1…A360, B1… etc.
N_sats = N_planes * sats_per_plane; % Total number of satellites
orbitNames = makeOrbitNames(N_planes); % Cell array of plane names ('A','B',…)
satLabels = cell(N_sats,1);         % Preallocate cell array for satellite labels
for p = 1:N_planes                  % Loop over each orbital plane
    for s = 1:sats_per_plane        % Loop over each satellite in the plane
        idx = (p-1)*sats_per_plane + s;   % Compute global satellite index
        satLabels{idx} = sprintf('%s%d', orbitNames{p}, s); % Label like 'A1'
    end                              % End satellite loop
end                                  % End plane loop

%% 3) SEMI‑MAJOR AXIS & ECCENTRICITY FIXED
rp = Re + hp;                        % Compute perigee radius
ra = Re + ha;                        % Compute apogee radius
a  = (rp + ra)/2;                    % Compute semi-major axis
e  = 0.1205;                         % Set orbital eccentricity
fprintf('Orbit hp=%.0f km, ha=%.0f km -> a=%.1f km, e=%.4f\n', ...
        hp/1e3, ha/1e3, a/1e3, e);   % Print orbit parameters to console

%% 4) BUILD ORBIT ELEMENTS (Walker Δ)
orbit_elements = zeros(6, N_sats);  % Preallocate [a; e; i; RAAN; ω; M₀]
idx = 0;                             % Initialize satellite counter
for p = 0:(N_planes-1)               % Loop over plane index for RAAN
    RAAN  = deg2rad(p * 360/N_planes); % Compute RAAN in radians
    omega = 0;                       % Set argument of perigee to zero
    for s = 0:(sats_per_plane-1)    % Loop over satellites for mean anomaly
        idx = idx + 1;              % Increment global satellite index
        phase_deg = mod(s*360/sats_per_plane + F*(360/N_planes)*p, 360); % Delta phase
        M0 = deg2rad(phase_deg);    % Convert phase to initial mean anomaly
        orbit_elements(:,idx) = [a; e; inc; RAAN; omega; M0]; % Store elements
    end                              % End satellite loop
end                                  % End plane loop

%% 5) APOGEE‑REGION FILTER (10% of sats)
numApo   = round(0.10 * N_sats);    % Number of satellites nearest apogee
phaseAll = mod(orbit_elements(6,:), 2*pi); % Normalize M₀ between 0 and 2π
[~, sortIdx] = sort(abs(phaseAll - pi)); % Sort by closeness to apogee (π)
apoIdx   = sortIdx(1:numApo);        % Indices of top 10% near apogee
fprintf('Filtering to %d sats nearest apogee for distance calcs.\n\n', numApo); % Log

%% 6) PROPAGATE ORBITS
mu     = 3.986004418e14;            % Earth's gravitational parameter [m^3/s^2]
dt     = 10;                        % Time step for propagation [s]
tvec   = 0:dt:2*pi*sqrt(a^3/mu);    % Time vector for one orbital period
Nt     = numel(tvec);               % Number of time steps
sat_pos = zeros(3, Nt, N_sats);     % Preallocate positions [x;y;z]

for k = 1:N_sats                     % Loop over each satellite
    a_k    = orbit_elements(1,k);    % Semi-major axis for sat k
    e_k    = orbit_elements(2,k);    % Eccentricity for sat k
    i_k    = orbit_elements(3,k);    % Inclination for sat k
    RAAN_k = orbit_elements(4,k);    % RAAN for sat k
    M0_k   = orbit_elements(6,k);    % Initial mean anomaly for sat k
    n_mean = sqrt(mu/a_k^3);         % Mean motion [rad/s]
    for tN = 1:Nt                    % Loop over time steps
        M = M0_k + n_mean * tvec(tN);     % Update mean anomaly
        E = solveKepler(M, e_k);          % Solve Kepler's equation for E
        nu = 2*atan2(sqrt(1+e_k)*sin(E/2), ... % Compute true anomaly ν
                     sqrt(1-e_k)*cos(E/2));
        r_pf = a_k*(1-e_k^2)/(1+e_k*cos(nu)) ... % Radius in perifocal frame
               * [cos(nu); sin(nu); 0];
        Q    = rotationMatrix(RAAN_k, i_k, 0);   % Perifocal→ECI rotation matrix
        sat_pos(:,tN,k) = Q * r_pf;         % Store ECI position
    end                                  % End time loop
end                                      % End satellite loop

%% 7) VISUALIZATION: Earth, Orbits, Sampled Satellites
img = imread('BlueMarble_5400x2700.jpg'); % Load Earth texture image
[XS,YS,ZS] = sphere(180);               % Generate unit sphere coordinates
figure(1); clf; set(gcf,'Color','k');    % Create black-background figure
surf(XS*Re, YS*Re, ZS*Re, ...            % Map texture onto sphere
     'FaceColor','texturemap', ...
     'CData',img, 'EdgeColor','none');
axis equal off; camlight headlight; lighting phong; hold on; % Beautify plot

% Plot semi-transparent yellow orbit tracks
for k = 1:N_sats
    plot3(sat_pos(1,:,k), sat_pos(2,:,k), sat_pos(3,:,k), ...
          'y','LineWidth',0.5,'Color',[1 1 0 0.15]);
end
% Plot red dots for every 10th satellite at t=0
dotIdx = 1:10:N_sats;                  
for k = dotIdx
    r0 = sat_pos(:,1,k);               % Position at t=0
    plot3(r0(1), r0(2), r0(3), 'r.','MarkerSize',8);
end
title('Behold! The Helianthus Constellation'); % Title
view([45 30]);                            % Set 3D camera view

%% 8) DISTANCE & CLOSEST‑PAIR IDENTIFICATION
pair_count = nchoosek(numApo,2);       % Total pairs among apogee sats
minD_vals  = inf(pair_count,1);        % Preallocate min-distance array
pairIdx    = zeros(pair_count,2);      % Preallocate index pairs
m = 0;                                 % Pair counter
for ii = 1:numApo                      % Loop over first sat in pair
    i  = apoIdx(ii);                   % Global index of sat i
    Pi = squeeze(sat_pos(:,:,i));      % Trajectory of sat i
    for jj = ii+1:numApo               % Loop over second sat
        j = apoIdx(jj);                % Global index of sat j
        m = m + 1;                     % Increment pair counter
        pairIdx(m,:) = [i j];          % Store the index pair
        Pj = squeeze(sat_pos(:,:,j));  % Trajectory of sat j
        d_ij = min(sqrt(sum((Pi-Pj).^2,1))); % Closest approach
        minD_vals(m) = d_ij;           % Save min distance
    end
end
[minVal, minIdx] = min(minD_vals);     % Find overall minimum distance
iSat = pairIdx(minIdx,1);              % Index of first sat in closest pair
jSat = pairIdx(minIdx,2);              % Index of second sat
closestStr = sprintf('Closest pair: %s & %s (%.2f km)', ...
                     satLabels{iSat}, satLabels{jSat}, minVal/1e3); % Format text
fprintf('%s\n', closestStr);           % Display closest-pair info

% Annotate plot with closest-pair text
annotation('textbox',[0.3 0.05 0.4 0.05], ...
           'String',closestStr, ...
           'Color','w','FontSize',12,'FontWeight','bold', ...
           'EdgeColor','none','HorizontalAlignment','center');

%% 9) VIOLIN & KDE PLOTS
minD_km = minD_vals/1e3;               % Convert distances to kilometers
min_sep = min(minD_km);                % Find the minimum separation

figure(2); clf;                        % New figure for violin plot
violinplot(minD_km);                   % Plot violin of min distances
ylabel('Min Distance (km)');           % Y-axis label
title('Pairwise Closest‑Approach Distances'); % Title
grid on;                               % Enable grid
hold on;                               % Retain the violin plot
yline(min_sep, 'r--', sprintf('Min = %.2f km', min_sep));  % Red dashed line at min separation

x_kde = linspace(min(minD_km), max(minD_km), 300); % KDE x-values
bw    = 20;                            % Bandwidth for kernel
f_kde = zeros(size(x_kde));           % Preallocate KDE array
for ii = 1:numel(minD_km)             % Sum Gaussian kernels
    f_kde = f_kde + exp(-(x_kde-minD_km(ii)).^2/(2*bw^2));
end
f_kde = f_kde/(numel(minD_km)*bw*sqrt(2*pi)); % Normalize KDE

figure(3); clf;                        % New figure for KDE plot
plot(x_kde, f_kde, 'r-','LineWidth',2);% Plot density curve
xlabel('Min Distance (km)');           % X-axis label
ylabel('Density');                     % Y-axis label
title('KDE of Closest‑Approach Distances'); % Title
grid on;                               % Enable grid

%% --- SUBFUNCTIONS ---
function R = rotationMatrix(RAAN, i, omega)
    Rz1 = [cos(RAAN) sin(RAAN) 0; ... % Rotation about z by RAAN
          -sin(RAAN) cos(RAAN) 0; 0 0 1];
    Rx  = [1 0 0; ...               % Rotation about x by inclination
           0 cos(i) sin(i); 
           0 -sin(i) cos(i)];
    Rz2 = [cos(omega) sin(omega) 0; % Rotation about z by argument of perigee
          -sin(omega) cos(omega) 0; 0 0 1];
    R = Rz1 * Rx * Rz2;             % Combined rotation matrix
end

function E = solveKepler(M, e)
    E = M;                          % Initialize eccentric anomaly guess
    for k = 1:50                    % Newton–Raphson iterations
        f  = E - e*sin(E) - M;      % Kepler's equation residual
        fp = 1 - e*cos(E);          % Derivative of residual
        E  = E - f./fp;             % Update eccentric anomaly
    end
end

function names = makeOrbitNames(P)
    names = cell(P,1);             % Preallocate cell array
    for k = 1:P                     % Loop over plane count
        names{k} = num2letters(k); % Convert index to letters
    end
end

function s = num2letters(n)
    s = '';                         % Initialize string
    while n > 0                     % While there are letters to assign
        r = mod(n-1,26);            % Remainder for letter
        s = [char('A'+r) s];        % Prepend corresponding letter
        n = floor((n-1)/26);        % Move to next letter position
    end
end
