classdef Haikunator < handle
    % Haikunator Class for generating random haiku-like names
    %
    % Stephen Holtz 2018
    properties (Access = private)
        seed
        adjectives
        nouns

        min_ver = '9.2' % matlab 2017a
    end
    
    properties (Access = private, Constant = true)
        % Default values stored here
        adjectives_ = {'aged', 'ancient', 'autumn', 'billowing', 'bitter', 'black', 'blue', ...
            'bold','broad', 'broken', 'calm', 'cold', 'cool', 'crimson', 'curly', 'damp', ...
            'dark', 'dawn', 'delicate', 'divine', 'dry', 'empty', 'falling', 'fancy', ...
            'flat', 'floral', 'fragrant', 'frosty', 'gentle', 'green', 'hidden', 'holy', ...
            'icy', 'jolly', 'late', 'lingering', 'little', 'lively', 'long', 'lucky', ...
            'misty', 'morning', 'muddy', 'mute', 'nameless', 'noisy', 'odd', 'old', ...
            'orange', 'patient', 'plain', 'polished', 'proud', 'purple', 'quiet', 'rapid', ...
            'raspy', 'red', 'restless', 'rough', 'round', 'royal', 'shiny', 'shrill', ...
            'shy', 'silent', 'small', 'snowy', 'soft', 'solitary', 'sparkling', 'spring', ...
            'square', 'steep', 'still', 'summer', 'super', 'sweet', 'throbbing', 'tight', ...
            'tiny', 'twilight', 'wandering', 'weathered', 'white', 'wild', 'winter', 'wispy', ...
            'withered', 'yellow', 'young'}
        nouns_ = {'art', 'band', 'bar', 'base', 'bird', 'block', 'boat', 'bonus', ...
            'bread', 'breeze', 'brook', 'bush', 'butterfly', 'cake', 'cell', 'cherry', ...
            'cloud', 'credit', 'darkness', 'dawn', 'dew', 'disk', 'dream', 'dust', ...
            'feather', 'field', 'fire', 'firefly', 'flower', 'fog', 'forest', 'frog', ...
            'frost', 'glade', 'glitter', 'grass', 'hall', 'hat', 'haze', 'heart', ...
            'hill', 'king', 'lab', 'lake', 'leaf', 'limit', 'math', 'meadow', ...
            'mode', 'moon', 'morning', 'mountain', 'mouse', 'mud', 'night', 'paper', ...
            'pine', 'poetry', 'pond', 'queen', 'rain', 'recipe', 'resonance', 'rice', ...
            'river', 'salad', 'scene', 'sea', 'shadow', 'shape', 'silence', 'sky', ...
            'smoke', 'snow', 'snowflake', 'sound', 'star', 'sun', 'sun', 'sunset', ...
            'surf', 'term', 'thunder', 'tooth', 'tree', 'truth', 'union', 'unit', ...
            'violet', 'voice', 'water', 'waterfall', 'wave', 'wildflower', 'wind', 'wood'}
        delimiter_ = '-';
        token_chars_ = '0123456789';
        token_length_ = 4;
        use_token_hex_ = false;
    end

    methods
        function obj = Haikunator(options)
            % h = Haikunator()
            % 
            % All inputs are optional. Calling Haikunator() is equivalent 
            % to seed_ = rng(); Haikunator('seed',seed_).
            %
            % Optional Inputs
            % ---------------
            % seed       : nonnegative integer, if not entered, defaults to a
            %              random seed from rng(), prime numbers \in [31,2^17-1]
            % adjectives : cell array of adjectives (also accepts a single string)
            % nouns      : cell array of nouns (also accepts a single string)
            %
            % Examples
            % --------
            % h = Haikunator('seed',313)
            % h = Haikunator('adjectives',{'frank','jocular','frazzled'})
            % h = Haikunator('nouns',{'plumbus','olifant'})

            arguments
               options.seed         (1,1) {mustBeNonnegative}
               options.adjectives   (1,:) {mustBeText}
               options.nouns        (1,:) {mustBeText}
            end

            if verLessThan('matlab',obj.min_ver)
                error(['MATLAB version must be >=' obj.min_ver]);
            end

            % Set hidden properties
            if ~isfield(options,"seed")
                obj.seed = rng('shuffle');
            else
                obj.seed = options.seed;
            end

            if ~isfield(options,"adjectives")
                obj.adjectives = obj.adjectives_;
            else % Ensure cell array
                if ischar(options.adjectives)
                    obj.adjectives = {options.adjectives};
                else
                    obj.adjectives = options.adjectives;
                end
            end
            
            if ~isfield(options,"nouns")
                obj.nouns = obj.nouns_;
            else % Ensure cell array
                if ischar(options.nouns)
                    obj.nouns = {options.nouns};
                else
                    obj.nouns = options.nouns;
                end
            end
        end

        function name = haikunate(obj,options)
            % name = haikunate('delimiter','-','token_length',4,'token_chars','0123456789','token_hex',false)
            % 
            % All inputs are optional, and use the seed passed (implicitly or explicitly) to 
            % the Haikunator constructor for randomization.
            %
            % Optional Inputs
            % ---------------
            % delimiter     : string to delimit the adjective noun and token
            %                 defaults to '-'.
            % token_length  : integer to specify the length of the token, 
            %                 defaults to 4.
            % token_chars   : string to serve as pool for token, defaults to
            %                 '0123456789'.
            % use_token_hex : boolean, if true sets token_chars to 
            %                 hexidecimal values '0123456789abcdef', will
            %                 override anything passed to token_chars.
            %                 Defaults to false (if true will override
            %                 token_chars input).
            %
            % Examples (with different seeds)
            % -------------------------------
            % h = Haikunator();
            %
            % % Standard useage
            % h.haikunate(); % = 'still-sun-8919'
            %
            % % Use underscores as delimiter
            % h.haikunate('delimiter','_'); % = 'orange_morning_5786'
            % 
            % % Use hex token
            % h.haikunate('use_token_hex',true); % = 'lively-hill-6b04'
            %
            % % Change token_chars
            % h.haikunate('token_chars','HAIKUNATOR'); % 'lucky-king-UHNU'
            
            % Parse inputs
            arguments
                obj

                options.delimiter       (1,:) {mustBeText} = obj.delimiter_
                options.token_length    (1,1) {mustBeNonnegative} = obj.token_length_
                options.token_chars     (1,:) {mustBeText} = obj.token_chars_
                options.use_token_hex   (1,1) {mustBeNumericOrLogical} = obj.use_token_hex_
            end

            if options.use_token_hex
                token_chars = '0123456789abcdef';
            else
                token_chars = options.token_chars;
            end

            % Make name
            adjective = cell2mat(obj.getRandom(obj.adjectives,1));
            noun = cell2mat(obj.getRandom(obj.nouns,1));
            token = obj.getRandom(token_chars,options.token_length);

            % Account for zero token length
            if options.token_length == 0
                name = [adjective, options.delimiter, noun];    
            else
                name = [adjective, options.delimiter, noun, options.delimiter, token];
            end
        end
    end
    
    methods (Access = private)
        function elements = getRandom(obj,lst,n_elements)
            % Return a random element or random set, with replacement. Also
            % retains previous rng() values.

            % Save current seed
            old_rng = rng();

            rng(obj.seed);
            if n_elements == 1
                if length(lst) == 1
                    elements = lst;
                else
                    elements = lst(randi(length(lst)));
                end
            else
                elements = repmat(' ',1,n_elements);
                for i = 1:n_elements
                    elements(i) = lst(randi(length(lst)));
                end
            end

            % Return to old seed
            rng(old_rng.Seed);
        end
    end
end