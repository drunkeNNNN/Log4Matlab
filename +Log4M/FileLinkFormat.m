% Global definition of the Logger setting, which determines the file link format.
classdef FileLinkFormat
    properties(Constant,Access=public)
        OFF=0;
        FILENAME=1;
        CLASS_AND_METHOD=2;
        FULL=3;
    end
end

