classdef LogExampleClass<handle
    properties(Access=private)
        logger=Log4Matlab.Logger.getInstance();
    end

    methods(Static)
        function aStaticClassMethodLogging()
            l=Log4Matlab.Logger.getInstance();
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
    end
end

