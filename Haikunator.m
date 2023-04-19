classdef Haikunator < handle
    % Haikunator Class for generating random haiku-like names
    %
    % Stephen Holtz
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
            'withered', 'yellow', 'young', 'azure', 'brilliant', 'celestial', 'charming', ...
            'chilly', 'crystal', 'dazzling', 'electric', 'enchanting', 'fickle', 'flaming', ...
            'gloomy', 'glorious', 'graceful', 'hazy', 'heavenly', 'idyllic', 'innocent', ...
            'majestic', 'misty', 'mystical', 'nebulous', 'opal', 'peaceful', 'radiant', ...
            'serene', 'shimmering', 'silvery', 'sizzling', 'sleek', 'slumbering', 'soothing', ...
            'spellbinding', 'starlit', 'stormy', 'sublime', 'tranquil', 'velvet', 'vibrant', ...
            'whimsical', 'willowy', 'wondrous', 'zesty'}
        nouns_ = {'apple', 'autumn', 'breeze', 'brook', 'butterfly', 'cloud', 'coast', ...
            'crystal', 'dawn', 'dew', 'dream', 'dusk', 'field', 'fire', 'flame', 'flower', ...
            'fog', 'forest', 'garden', 'gem', 'grass', 'haze', 'hill', 'horizon', 'lake', ...
            'leaf', 'light', 'mist', 'moon', 'morning', 'mountain', 'ocean', 'orchard', ...
            'pebble', 'pine', 'pond', 'rain', 'rainbow', 'river', 'rock', 'rose', 'sand', ...
            'sea', 'shadow', 'shimmer', 'sky', 'snow', 'sparkle', 'star', 'stone', 'stream', ...
            'sun', 'sunset', 'surf', 'thorn', 'thunder', 'tide', 'tree', 'twilight', 'valley', ...
            'vapor', 'water', 'wave', 'whisper', 'willow', 'wind', 'wood', 'world', 'yawn', ...
            'zeal', 'aerial', 'amber', 'angel', 'azure', 'beacon', 'blossom', 'breeze', ...
            'brilliance', 'canyon', 'cascade', 'celestial', 'charm', 'cliff', 'coral', ...
            'cove', 'crystal', 'dazzle', 'diamond', 'dream', 'ebony', 'eden', 'emerald', ...
            'enchantment', 'essence', 'fjord', 'forest', 'glimmer', 'glow', 'golden', ...
            'grace', 'harbor', 'haven', 'haze', 'horizon', 'illuminance', 'island', 'jewel', ...
            'lake', 'lantern', 'lilac', 'majesty', 'meadow', 'midnight', 'miracle', 'moonlight', ...
            'morning', 'mystery', 'oasis', 'ocean', 'opulence', 'pearl', 'peak', 'perfection', ...
            'petal', 'purity', 'radiance', 'rainbow', 'reflection', 'river', 'serenity', ...
            'shadow', 'shimmer', 'silhouette', 'silver', 'soothe', 'sparkle', 'splendor', ...
            'spring', 'starlight', 'storm', 'stream', 'sunrise', 'sunset', 'tide', 'tranquility', ...
            'treasure', 'twilight', 'vibrance', 'violet', 'waterfall', 'wave', 'whisper', ...
            'wilderness', 'willow', 'wonder', 'zenith'};
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
