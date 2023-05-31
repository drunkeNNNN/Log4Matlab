classdef TextFile<Log4M.Appenders.Appender
    properties(Access=private)
        outputFilePath char;
    end

    methods(Access=public)
        function obj=setOutputFilePath(obj, outputFilePath,createDatePostfix)
            arguments
                obj Log4M.Appenders.TextFile;
                outputFilePath char;
                % Whether or not the present date is added to the output filename.
                createDatePostfix=false;
            end
            if createDatePostfix
                datePostfix=['_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
            else
                datePostfix='';
            end
            [folder,file,ext]=fileparts(outputFilePath);
            if isempty(folder)
                folder=pwd();
            end
            obj.outputFilePath=[folder,filesep,file,datePostfix,ext];
        end

        function newFile(obj,outputFilePath,enableDatePrefix)
            % wrapper
            obj.setOutputFilePath(outputFilePath,enableDatePrefix);
        end

        % Function called by the Logger
        function appendToLog(obj,logLevel,sourceFilename,sourceLink,message,errorLineLink)
            if isempty(obj.outputFilePath)
                obj.newFile();
            end
            
            try
                fid = fopen(obj.outputFilePath,'a+');
                if obj.verboseModeEnabled
                    fprintf(fid,'%s %s %s: %s\r\n' ...
                        , char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) ...
                        , logLevel ...
                        , sourceFilename ...
                        , message);
                else
                    fprintf(fid,'%s %s\r\n', logLevel,message);
                end
                fclose(fid);
            catch ME_1
                disp(ME_1);
            end
        end
    end
end

