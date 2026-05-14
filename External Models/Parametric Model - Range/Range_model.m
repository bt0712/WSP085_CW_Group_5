% Range_model.m
% Reads UAV_Mass from Parameter Exchange.xlsx
% Calculates UAV cruise range
% Writes result back to UAV_Cruise_Range in same sheet

clear; clc; close all;

%% File location

script_folder = fileparts(mfilename('fullpath'));
new_path = script_folder(1:end-41);
input_file = fullfile(new_path, 'Parameter Exchange.xlsx');

sheet_name = 'Report';

if ~isfile(input_file)
    error('Parameter Exchange.xlsx not found in the same folder as this MATLAB file.');
end

%% Read raw Excel sheet

raw = readcell(input_file, 'Sheet', sheet_name);

% Your Excel format:
% Column A = ID
% Column B = System
% Column C = Parameter name
% Column D = Unit
% Column E = Value

name_col  = 3;
value_col = 5;

%% Read parameters from existing sheet

UAV_Mass          = get_param(raw, name_col, value_col, 'UAV_Mass');
PS_Efficiency     = get_param(raw, name_col, value_col, 'PS_Efficiency');
Bat_Voltage       = get_param(raw, name_col, value_col, 'Bat_Voltage');
Bat_Capacity      = get_param(raw, name_col, value_col, 'Bat_Capacity');
Wing_MAC          = get_param(raw, name_col, value_col, 'Wing_MAC');
Wing_Span         = get_param(raw, name_col, value_col, 'Wing_Span')/100;
Struct_CL         = get_param(raw, name_col, value_col, 'Struct_CL');
Struct_CD0        = get_param(raw, name_col, value_col, 'Struct_CD0');
UAV_Cruise_Speed  = get_param(raw, name_col, value_col, 'UAV_Cruise_Speed');

%% Range calculation

rho_air = 1.225;
g = 9.81;

mass_kg = UAV_Mass;
weight_N = mass_kg * g;

S = Wing_MAC * Wing_Span;
AR = Wing_Span / Wing_MAC;

e = 1.78 * (1 - 0.045 * AR^0.68) - 0.64;

CD = Struct_CD0 + (Struct_CL^2) / (pi * e * AR);
LD = Struct_CL / CD;

battery_energy_J = Bat_Voltage * Bat_Capacity * 3600;

UAV_Cruise_Range = ...
    (PS_Efficiency * battery_energy_J / weight_N) * LD / 1000;

%% Display result

fprintf('\n========== PARAMETER EXCHANGE ==========\n');
fprintf('Mass read from Excel          = %.3f kg\n', mass_kg);
fprintf('Calculated L/D                = %.3f\n', LD);
fprintf('Calculated UAV_Cruise_Range   = %.3f km\n', UAV_Cruise_Range);
fprintf('========================================\n');

%% Write result back to existing UAV_Cruise_Range row

write_param(input_file, sheet_name, raw, name_col, value_col, ...
    'UAV_Cruise_Range', UAV_Cruise_Range);

fprintf('\nUAV_Cruise_Range updated in existing Report sheet.\n');

%% Helper function: read parameter

function val = get_param(raw, name_col, value_col, param_name)

    names = string(raw(:, name_col));

    row_idx = find(names == param_name, 1);

    if isempty(row_idx)
        error('Parameter "%s" not found in column C.', param_name);
    end

    raw_value = raw{row_idx, value_col};

    if isnumeric(raw_value)
        val = raw_value;
    else
        val = str2double(string(raw_value));
    end

    if isnan(val)
        error('Parameter "%s" does not contain a numeric value.', param_name);
    end
end

%% Helper function: write parameter

function write_param(input_file, sheet_name, raw, name_col, value_col, param_name, new_value)

    names = string(raw(:, name_col));

    row_idx = find(names == param_name, 1);

    if isempty(row_idx)
        error('Parameter "%s" not found in column C.', param_name);
    end

    cell_ref = sprintf('%s%d', excel_col(value_col), row_idx);

    writematrix(new_value, input_file, ...
        'Sheet', sheet_name, ...
        'Range', cell_ref);
end

%% Helper function: Excel column number to letter

function col = excel_col(n)

    col = "";

    while n > 0
        r = mod(n - 1, 26);
        col = char(65 + r) + col;
        n = floor((n - 1) / 26);
    end
end