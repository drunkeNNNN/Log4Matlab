classdef Filter < handle
    properties(Constant,Access=public)
        ACCEPT=categorical({'ACCEPT'});
        DENY=categorical({'DENY'});
        NEUTRAL=categorical({'NEUTRAL'});
    end

    properties(Access=private)
        onMatchAction;
        onMismatchAction;
    end

    methods(Access=public)
        function result=applyFilter(obj,message)
            doesMatch=obj.matches(message);
            if doesMatch
                result=obj.onMatchAction();
            else
                result=obj.onMismatchAction();
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
                action categorical;
            end
            obj.onMatchAction=action;
        end

        function obj=onMismatch(obj,action)
            arguments
                obj Filters.Regex;
                action categorical;
            end
            obj.onMismatchAction=action;
        end
    end
end