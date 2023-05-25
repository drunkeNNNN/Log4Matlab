classdef Filter < handle
    properties(Constant,Access=public)
        ACCEPT=categorical({'ACCEPT'});
        DENY=categorical({'DENY'});
        NEUTRAL=categorical({'NEUTRAL'});
    end

    properties(Access=private)
    end
    
    methods(Abstract,Access=public)
        filterResult=applyFilter(obj,message);
    end
end