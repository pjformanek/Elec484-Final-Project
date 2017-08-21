function varargout = dynamic_controller_gui(varargin)
% DYNAMIC_CONTROLLER_GUI MATLAB code for dynamic_controller_gui.fig
%      DYNAMIC_CONTROLLER_GUI, by itself, creates a new DYNAMIC_CONTROLLER
%      GUI or raises the existing singleton*.
%
%      H = DYNAMIC_CONTROLLER_GUI returns the handle to a new 
%      DYNAMIC_CONTROLLER_GUI or the handle to the existing singleton*.
%
%      DYNAMIC_CONTROLLER_GUI('CALLBACK',hObject,eventData,handles,...)
%      calls the local function named CALLBACK in DYNAMIC_CONTROLLER_GUI.M 
%      with the given input arguments.
%
%      DYNAMIC_CONTROLLER_GUI('Property','Value',...) creates a new 
%      DYNAMIC_CONTROLLER_GUI or raises the existing singleton*.  
%      Starting from the left, property value pairs are applied to the GUI
%      before dynamic_controller_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application stop.  All inputs are passed to
%      dynamic_controller_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, guidata, GUIHANDLES

% Edit the above text to modify the response to help dynamic_controller_gui

% Last Modified by GUIDE v2.5 25-Jul-2016 11:48:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dynamic_controller_gui_OpeningFcn,...
                   'gui_OutputFcn',  @dynamic_controller_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before dynamic_controller_gui is made visible.
function dynamic_controller_gui_OpeningFcn(hObject, eventdata, handles,...
                                            varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)
% varargin  command line arguments to dynamic_controller_gui (see VARARGIN)

% Setting up the Slider increment values
set(handles.cThreshSldr, 'SliderStep', [1/600, 1/60]);
set(handles.cRatioSldr, 'SliderStep', [1/90, 1/9]);
set(handles.cAtkSldr, 'SliderStep', [1/1000, 1/10]);
set(handles.cRlsSldr, 'SliderStep', [1/1000, 1/10]);
set(handles.eThreshSldr, 'SliderStep', [1/600, 1/60]);
set(handles.eRatioSldr, 'SliderStep', [1/90, 1/9]);
set(handles.eAtkSldr, 'SliderStep', [1/1000, 1/10]);
set(handles.eRlsSldr, 'SliderStep', [1/1000, 1/10]);

% added handles 
handles.params.fileLoaded = 0;
handles.params.sampleFreq = 0;
handles.params.workingFolder = pwd;
handles.params.lastStep = 0;
handles.envelope = 0;
handles.totalRawData = 0;
handles.changedData = 0;

% Choose default command line output for dynamic_controller_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setParams(hObject, handles);
updatePlot(handles);

% --- Updates the plot with latest parameters
function updatePlot (handles)
% this function will update the UI graph with the appropriate slopes
% based on threshold, and ratio values
% This function has no output args
% handles   structure with handles and user data (see guidata)

% breaking 60db into half steps for  better resolution on graph
yvalues = ones(120,1);

for n = 1:120
    if ((n-120) < 2*round(handles.eThreshSldr.Value))
        yvalues(n,1) = handles.eThreshSldr.Value + ((-60 + (n-1)/2) - ...
                           handles.eThreshSldr.Value)/ ...
                           handles.eRatioSldr.Value;
    elseif (n-120) >= 2*round(handles.eThreshSldr.Value) ...
            && (n-120 < 2*round(handles.cThreshSldr.Value))
        yvalues(n,1) = -60 + n/2;
    else
        yvalues(n,1) = handles.cThreshSldr.Value + ((-60 + n/2) - ...
                           handles.cThreshSldr.Value)/ ...
                           handles.cRatioSldr.Value; 
    end
end

xvalues = ones(120,1);
for n = 1:120
    xvalues(n,1) = -60 + (n-1)/2;
end
    plot(xvalues,yvalues);
    axis([-60 0 -60 0]);
    xlabel('X (dB)','FontSize',8);
    ylabel('Y (dB)','FontSize',8);
    handles.figure1.CurrentAxes.XGrid = 'on';
    handles.figure1.CurrentAxes.YGrid = 'on';
    handles.figure1.CurrentAxes.XMinorGrid = 'on';
    handles.figure1.CurrentAxes.YMinorGrid = 'on';

% UIWAIT makes dynamic_controller_gui wait for user response (see UIRESUME)
%    uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = dynamic_controller_gui_OutputFcn(hObject, ...
                                                      eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function cThreshSldr_Callback(hObject, eventdata, handles)
% hObject    handle to cThreshSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%    get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% makes sure expander threshold is lower than compressor threshold
roundedVal = round(get(hObject,'Value'), 1);
if (roundedVal >= handles.eThreshSldr.Value + 1);
    set(handles.cThreshBox, 'String',num2str(roundedVal));
else
    set(handles.cThreshSldr,'Value', str2double(handles.cThreshBox.String));
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function cThreshSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cThreshSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
           get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function cRatioSldr_Callback(hObject, eventdata, handles)
% hObject    handle to cRatioSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%    get(hObject,'Min') and get(hObject,'Max') to determine range of slider
roundedVal = round(get(hObject, 'Value'), 1);
set(handles.cRatioBox,'String',roundedVal);
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function cRatioSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cRatioSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
           get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function cAtkSldr_Callback(hObject, eventdata, handles)
% hObject    handle to cAtkSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%    get(hObject,'Min') and get(hObject,'Max') to determine range of slider
roundedVal = round(get(hObject, 'Value'), 3);
set(handles.cAtkBox,'String',roundedVal);
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cAtkSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cAtkSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
           get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function cRlsSldr_Callback(hObject, eventdata, handles)
% hObject    handle to cRlsSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%         slider
roundedVal = round(get(hObject, 'Value'), 3);
set(handles.cRlsBox,'String',roundedVal);
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cRlsSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cRlsSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes afte TextBox entry
function cThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to cThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of cThreshBox as text
%        str2double(get(hObject,'String')) returns contents of 
%         cThreshBox as a double

val = round(str2double(get(hObject, 'String')),1);
range = get(handles.cThreshSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2} && ...
        val > handles.eThreshSldr.Value)
       set(handles.cThreshSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},1);
       set(hObject,'String',oldVal);
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function cThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes after textbox entry
function cRatioBox_Callback(hObject, eventdata, handles)
% hObject    handle to cRatioBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of cRatioBox as text
%        str2double(get(hObject,'String')) returns contents of cRatioBox as
%         a double

val = round(str2double(get(hObject, 'String')),1);
range = get(handles.cRatioSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.cRatioSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},1);
       set(hObject,'String',oldVal);
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function cRatioBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cRatioBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes after textbox entry
function cAtkBox_Callback(hObject, eventdata, handles)
% hObject    handle to cAtkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of cAtkBox as text
%        str2double(get(hObject,'String')) returns contents of cAtkBox as a
%         double

val = round(str2double(get(hObject, 'String')),3);
range = get(handles.cAtkSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.cAtkSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},3);
       set(hObject,'String',oldVal);
end
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cAtkBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cAtkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes after textbox entry
function cRlsBox_Callback(hObject, eventdata, handles)
% hObject    handle to cRlsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of cRlsBox as text
%        str2double(get(hObject,'String')) returns contents of cRlsBox as a
%         double

val = round(str2double(get(hObject, 'String')),3);
range = get(handles.cRlsSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.cRlsSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},3);
       set(hObject,'String',oldVal);
end
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cRlsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cRlsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in fileLoadBtn.
function fileLoadBtn_Callback(hObject, eventdata, handles)
% hObject    handle to fileLoadBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

[filename,filepath]=uigetfile({'*.wav','WAV files (*.wav)';...
    '*.ogg','OGG (*.ogg)';'*.flac','FLAC (*.flac)'; ...
    '*.mp3','MP3 (*.mp3)';'*.mp4;*.m4a','MPEG-4 AAC'},...
   'Select an audio file');
newFileName = ' ';
len = length(filename);
extension = '   ';
index = 1;
if (filename == 0)
        set(handles.fileNameBox, 'String', 'pick a file');
        handles.params.fileLoaded = 0;
        set(handles.fileNameBox, 'FontAngle', 'italic');
else
    for n = len-2:len
        extension(index) = filename(n);
        index = index + 1;
    end
    try
    if (validatestring(extension, {'wav' 'ogg' 'flac' 'mp3' 'mp4' 'm4a'}))
        cd(filepath);                 
        handles.audioReader = dsp.AudioFileReader(filename);
        handles.params.sampleFreq = sampleRate;
        handles.params.fileLoaded = 1;
        set(handles.fileNameBox, 'FontAngle', 'normal');
    end
    catch
    end
    if (handles.params.fileLoaded)
         %if(filename contains .mp3)
         %   mp3filename equals filename with new .wav extension
        if(strcmp(extension, 'mp3'))             
            filename = strrep(filename, '.mp3', '.wav');
        end
        newFileName = strcat('NEW_',filename);
        writeLocation = strcat(filepath,newFileName);
        format = upper(extension);
        handles.audioWriter = dsp.AudioFileWriter(writeLocation, ...
                    'FileFormat', format, 'SampleRate', ...
                    handles.audioReader.SampleRate);
        set(handles.fileNameBox, 'String', filename);
        cd(handles.params.workingFolder);
    end
end
% sets the parameters based on newly acquired sample frequency
setParams(hObject, handles);

function fileNameBox_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of fileNameBox as text
%        str2double(get(hObject,'String')) returns contents of fileNameBox
%         as a double

% --- Executes during object creation, after setting all properties.
function fileNameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function eThreshSldr_Callback(hObject, eventdata, handles)
% hObject    handle to eThreshSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% makes sure expander threshold is lower than compressor threshold
roundedVal = round(get(hObject,'Value'), 1);
if (roundedVal < handles.cThreshSldr.Value - 1);
    handles.eThreshBox.String = num2str(roundedVal);
else
    handles.eThreshSldr.Value = str2double(handles.eThreshBox.String);
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function eThreshSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eThreshSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function eRatioSldr_Callback(hObject, eventdata, handles)
% hObject    handle to eRatioSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
roundedVal = round(get(hObject, 'Value'), 1);
set(handles.eRatioBox,'String',roundedVal);
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function eRatioSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRatioSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function eAtkSldr_Callback(hObject, eventdata, handles)
% hObject    handle to eAtkSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
roundedVal = round(get(hObject, 'Value'), 3);
set(handles.eAtkBox,'String',roundedVal);
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eAtkSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eAtkSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function eThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to eThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of eThreshBox as text
%        str2double(get(hObject,'String')) returns contents of eThreshBox as a double
val = round(str2double(get(hObject, 'String')),1);
range = get(handles.eThreshSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2} && ...
        val < handles.cThreshSldr.Value)
       set(handles.eThreshSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},1);
       set(hObject,'String',oldVal);
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function eThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eRatioBox_Callback(hObject, eventdata, handles)
% hObject    handle to eRatioBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of eRatioBox as text
%        str2double(get(hObject,'String')) returns contents of eRatioBox as a double
val = round(str2double(get(hObject, 'String')),1);
range = get(handles.eRatioSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.eRatioSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},1);
       set(hObject,'String',oldVal);
end
guidata(hObject);
updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function eRatioBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRatioBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eAtkBox_Callback(hObject, eventdata, handles)
% hObject    handle to eAtkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of eAtkBox as text
%        str2double(get(hObject,'String')) returns contents of eAtkBox as a double
val = round(str2double(get(hObject, 'String')),3);
range = get(handles.eAtkSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.eAtkSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},3);
       set(hObject,'String',oldVal);
end
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eAtkBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eAtkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eRlsBox_Callback(hObject, eventdata, handles)
% hObject    handle to eRlsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'String') returns contents of eRlsBox as text
%        str2double(get(hObject,'String')) returns contents of eRlsBox as a double
val = round(str2double(get(hObject, 'String')),3);
range = get(handles.cRlsSldr, {'Min','Max','Value'});

% checks for validity of input range
if (val >= range{1} && val <= range{2})
       set(handles.cRlsSldr,'Value',val);
       set(hObject, 'String', val);
else
       oldVal = round(range{3},3);
       set(hObject,'String',oldVal);
end
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eRlsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRlsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function eRlsSldr_Callback(hObject, eventdata, handles)
% hObject    handle to eRlsSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
roundedVal = round(get(hObject, 'Value'), 3);
set(handles.eRlsBox,'String',roundedVal);
guidata(hObject);
setParams(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eRlsSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRlsSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in applyBtn.
function applyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to applyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% move back to original working directory if changed to load file
cd(handles.params.workingFolder);
currentFrame = 0;
if (handles.params.fileLoaded == 0)
    modaldlg('Error','No file loaded','error');
    fileLoadBtn_Callback(hObject, eventdata, handles);
else
    cd(handles.params.workingFolder);
    while ~isDone(handles.audioReader)
        lastSample = currentFrame(end);
        currentFrame = step(handles.audioReader);
        processedFrame = process (hObject, handles, ...
                                    currentFrame, lastSample);  
        step (handles.audioWriter, processedFrame);
    end
end

% --- applies the dynamic controller, most of the work is done here
function processedFrame = process (hObject, handles, ...
                                    currentFrame, lastSample)
% first the envelope is determined, conversion to db,then the appropriate 
% gain value is determined, conversion back to linear, and the linear gain 
% value is applied to the input to produce the output.

cRatio = handles.cRatioSldr.Value;
eRatio = handles.eRatioSldr.Value;
cThreshold = handles.cThreshSldr.Value;
eThreshold = handles.eThreshSldr.Value;
g_n = 1;
[row, col] = size(currentFrame);
Data = zeros(row,col);

for chan = 1:col
    x_n = abs(currentFrame(:,chan));
    len = length(x_n);
    changedData = zeros(len,1);
    xrms = 0;
   
    for n = 1:len
        % rms envelope detection, each iteration uses the last value of 
        % xrms representing xrms(n-1), TAV = 0.1
        %rms[n] = (1-TAV)*rms[n-1] + TAV * input[n]^2
        xrms = 0.9*xrms + 0.1*x_n(n)*x_n(n);
        % converts envelope to dB
        if (xrms < 0.000001)
            envelopedB = -120;
        else
            envelopedB = 10*log10(xrms);
        end
        cStaticGain = (1 - 1/cRatio) * (cThreshold - envelopedB);
        eStaticGain = (1 - 1/eRatio) * (eThreshold - envelopedB);
      
        %determines if compressor or expander should be applied
        if envelopedB > cThreshold
            F_n = cStaticGain;
        elseif envelopedB < eThreshold
            F_n = eStaticGain;
        else 
            F_n = 0;
        end
        
        % convert back to linear
        % dividing by 20 instead of 10 for auto gain compensation
        f_n = 10^(F_n/20);
        if (f_n < g_n)
            if (F_n == cStaticGain)
                coeff = handles.params.coeffs.cat;
            else
                coeff = handles.params.coeffs.eat;
            end
        else
            if (F_n == cStaticGain)
                coeff = handles.params.coeffs.crt;
            else
                coeff = handles.params.coeffs.ert;
            end
        end
        g_n = ((1-coeff) * g_n) + (coeff * f_n);
        changedData(n) = g_n * handles.rawData(n);
    end
    
    % Builds up total audio one channel at a time
    if chan == 1
        Data = changedData;
    else 
        for n = 2:col
            Data = [Data , changedData];
        end
    end
end
audiowrite(handles.params.newFileName, Data, handles.params.sampleFreq);
msgbox('Processing Complete', 'Finished');
%updates the handles
guidata(hObject);

% --- sets the attack time, release time and parameters
function setParams (hObject, handles)
% hObject   handle to the GUI component that called the function
% handles   structure with hanels and user data (see guidata)

handles.params.coeffs.cat = 1 - exp(-2.2 /(handles.params.sampleFreq * ...
                                    handles.cAtkSldr.Value));
handles.params.coeffs.crt = 1 - exp(-2.2 /(handles.params.sampleFreq * ...
                                    handles.cRlsSldr.Value));
handles.params.coeffs.eat = 1 - exp(-2.2 /(handles.params.sampleFreq * ...
                                    handles.eAtkSldr.Value));
handles.params.coeffs.ert = 1 - exp(-2.2 /(handles.params.sampleFreq * ...
                                    handles.eRlsSldr.Value));
% updates the handles
guidata(hObject, handles);
