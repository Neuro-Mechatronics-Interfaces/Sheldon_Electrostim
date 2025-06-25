classdef (ConstructOnLoad) StimEventData < event.EventData
    %STIMEVENTDATA  Issued when the DS8R GUI "START" button is successfully engaged.
    
    properties (Access=public)
        Pulse_Amplitude_mA          % Column of `metadata.xlsx`
        Pulse_Width_ms              % Column of `metadata.xlsx`
        N_Pulses_Per_Burst          % Column of `metadata.xlsx`
        Pulse_Frequency             % Column of `metadata.xlsx`
        Inter_Pulse_Period_ms       % Column of `metadata.xlsx`
        Pulse_Type                  % Column of `metadata.xlsx`
        Date                        % Column of `metadata.xlsx`
    end
    
    methods
        function evt = StimEventData(data)
            %STIMEVENTDATA  Issued when the DS8R GUI "START" button is successfully engaged.
            %
            % Syntax:
            %   evt = StimEventData(data);
            %
            % Inputs:
            %   data - DS8R_Stim_GUI.WaveformTable.Data (cell array)
            %       This array is organized as:
            %  { PulseAmplitude_mA_1, Pulse_Width_ms_1, N_Pulses_Per_Burst_1, [Inter_Pulse_Period_ms_1 - PulseWidth_ms_1] }
            %       ...
            %  { PulseAmplitude_mA_k, Pulse_Width_ms_k, N_Pulses_Per_Burst_k, [Inter_Pulse_Period_ms_k - PulseWidth_ms_k] }
            %       
            % For an arbitrary number `k` of pulses in the stimulus
            % waveform.
            %
            % See also: Contents, DS8R_Stim_GUI.mlapp
            
            amp = cell2mat(data(:,1));
            pw = cell2mat(data(:,2))*0.1; % The pulsewidth is set a factor of 10 higher in the UI in order to produce a long enough trigger for TMSiSAGA to see it.
            % rep = cell2mat(data(:,3));
            tau = cell2mat(data(:,4));
            evt.Pulse_Amplitude_mA = mean(amp);
            
            if amp(1) == evt.Pulse_Amplitude_mA
                evt.N_Pulses_Per_Burst = numel(amp);
                evt.Pulse_Width_ms = mean(pw);
                if evt.Pulse_Amplitude_mA > 0
                    evt.Pulse_Type = "Cathodal";
                else
                    evt.Pulse_Type = "Anodal";
                end
                evt.Inter_Pulse_Period_ms = evt.Pulse_Width_ms + tau(1);
            else
                evt.N_Pulses_Per_Burst = ceil(numel(amp)/2);
                evt.Pulse_Width_ms = pw(1) + pw(2);
                if amp(1) > 0
                    evt.Pulse_Type = "Biphasic_Cathodal";
                else
                    evt.Pulse_Type = "Biphasic_Anodal";
                end
                evt.Inter_Pulse_Period_ms = evt.Pulse_Width_ms + tau(2);
            end
            evt.Pulse_Frequency = 1 / (1e-3 * evt.Inter_Pulse_Period_ms);
            evt.Date = datetime('now', 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS');
        end
    end
end




