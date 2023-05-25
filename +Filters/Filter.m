classdef Filter < handle
    properties(Constant,Access=public)
        ACCEPT=1;
        DENY=0;
        NEUTRAL=-1;
    end

    properties(Access=private)
        onMatchAction=Filters.Filter.NEUTRAL;
        onMismatchAction=Filters.Filter.NEUTRAL;
    end

    methods(Access=public)
        function result=applyFilter(obj,message)
            doesMatch=obj.matches(message);
            if doesMatch
                result=obj.onMatchAction;
            else
                result=obj.onMismatchAction;
            end
        end
    end

    methods(Abstract,Access=protected)
        filterResult=matches(obj,message);
    end

    methods(Access=public)
        function obj=onMatch(obj,action)
            arguments
                obj Filters.Regex;
                action double;
            end
            obj.onMatchAction=action;
        end

        function obj=onMismatch(obj,action)
            arguments
                obj Filters.Regex;
                action double;
            end
            obj.onMismatchAction=action;
        end
    end
end