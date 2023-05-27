classdef TextFile<Log4Matlab.Appenders.Appender
    properties(Access=private)
        outputFilePath char;
    end

    methods(Access=public)
        function obj=setOutputFilePath(obj, outputFilePath,enableDatePrefix)
%             arguments
%                 obj TextFile;
%                 outputFilePath char;
%                 enableDatePrefix (1,1) logical=false;
%             end
            if nargin<3
                enableDatePrefix=false;
            end
            if enableDatePrefix
                datePrefix=[char(datetime('now','Format','yyyyMMdd_HHmmSS')),'_'];
            else
                datePrefix='';
            end
            [folder,file,ext]=fileparts(outputFilePath);
            if isempty(folder)
                folder=pwd();
            end
            obj.outputFilePath=[folder,filesep,datePrefix,file,ext];
        end

        function newFile(obj)
            obj.setOutputFilePath('Matlab.log',true);
        end

        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.outputFilePath)
                obj.newFile();
            end
            
            try
                fid = fopen(obj.outputFilePath,'a+');
                if obj.verboseModeEnabled
                    fprintf(fid,'%s %s %s: %s\r\n' ...
                        , char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ...
                        , levelStr ...
                        , sourceFilename ...
                        , message);
                else
                    fprintf(fid,'%s\r\n', message);
                end
                fclose(fid);
            catch ME_1
                disp(ME_1);
            end
        end
    end
end

