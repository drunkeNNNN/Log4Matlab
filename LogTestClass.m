classdef LogTestClass<handle
    methods(Static)
        function aStaticClassMethodLogging(~)
            l=Log4Matlab.getInstance();
            l.info('A log from a static class method.')
        end
    end
    methods
        function aClassMethodLogging(~)
            l=Log4Matlab.getInstance();
            l.info('Log from a class method.');
        end
    end
end

