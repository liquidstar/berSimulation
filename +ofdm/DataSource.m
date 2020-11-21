classdef DataSource
	%
	% Source of random bits
	% Could have been a line in main.m
	% But an object was promised
	%
	properties (SetAccess = private)
		serialBits
	end
	methods
		function serialData = DataSource(bits)
			serialData.serialBits = rand(1,bits) > 0.5;
		end
	end
end
