% Global definition of the Logger setting, which determines the file link format.
classdef FileLinkFormat < double
    enumeration
        OFF (0);
        FILENAME (1);
        SOURCE_NAME (2);
        FULL (3);
    end
end

