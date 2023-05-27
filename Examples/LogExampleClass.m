% Example class for demonstaration purposes
classdef LogExampleClass<handle
    properties(Access=private)
        logger=Log4M.Logger.getInstance();
        identifier='LOG_4M_EXAMPLE_IDENTIFIER';
        data=rand(1,3)
    end

    methods(Static)
        function aStaticClassMethodLogging()
            l=Log4M.Logger.getInstance();
            l.info('A log from a static class method.')
        end
    end
    methods(Access=public)
        function aClassMethodLogging(obj)
            obj.logger.info('Log from a class method.');
        end

        function aClassMethodCrashingFatally(obj)
            errorData=rand(1,4);
            obj.logger.fatal('A fatal error occurred. Recovered data: ',errorData);
        end

        % implement the char function to parse the object for the logger
        function parsed=char(obj)
            parsed=[obj.identifier,': ',num2str(obj.data)];
        end
    end
end

