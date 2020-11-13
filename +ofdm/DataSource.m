classdef DataSource
    properties (SetAccess = private)
        serialBits
    end
    methods
        function serialData = DataSource(bits)
            serialData.serialBits = rand(1,bits) > 0.5;
        end
    end
end
