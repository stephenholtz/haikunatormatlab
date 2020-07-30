classdef Haikunator < handle
    % Haikunator Class for generating random haiku-like names
    %
    % Stephen Holtz 2018
    properties (Access = private)
        seed
        adjectives
        nouns
    end
    
    properties (Access = private, Constant = true)
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
    end
    
    methods
        function obj = Haikunator(varargin)
            % h = Haikunator()
            % 
            % All inputs are optional. Calling Haikunator() is equivalent 
            % to Haikunator('seed',randseed()).
            %
            % Optional Inputs
            % ---------------
            % seed       : nonnegative integer, if not entered, defaults to a
            %              random seed from randseed(), prime numbers \in [31,2^17-1]
            % adjectives : cell array of adjectives (also accepts a single string)
            % nouns      : cell array of nouns (also accepts a single string)
            %
            % Examples
            % --------
            % h = Haikunator('seed',313)
            % h = Haikunator('adjectives',{'frank','jocular','frazzled'})
            % h = Haikunator('nouns',{'plumbus','olifant'})
            
            % Parse inputs
            ip = inputParser();
            addParameter(ip,'seed', [], @(x) (isnumeric(x) && (mod(x,1) == 0 || x == 0))); % Check for nonnegative integer
            addParameter(ip,'adjectives', [], @(x) ischar(x) || iscellstr(x)); %#ok<ISCLSTR>
            addParameter(ip,'nouns', [], @(x) ischar(x) || iscellstr(x)); %#ok<ISCLSTR>
            
            parse(ip, varargin{:});
            
            % Set hidden properties
            if isempty(ip.Results.seed)
                obj.seed = rng('shuffle');
            else
                obj.seed = ip.Results.seed;
            end
            
            if isempty(ip.Results.adjectives)
                obj.adjectives = obj.adjectives_;
            else
                % Ensure cell array
                if ischar(ip.Results.adjectives)
                    obj.adjectives = {ip.Results.adjectives};
                else
                    obj.adjectives = ip.Results.adjectives;
                end
            end
            
            if isempty(ip.Results.nouns)
                obj.nouns = obj.nouns_;
            else
                % Ensure cell array
                if ischar(ip.Results.nouns)
                    obj.nouns = {ip.Results.nouns};
                else
                    obj.nouns = ip.Results.nouns;
                end
            end
        end
        
        function name = haikunate(obj,varargin)
            % name = haikunate('delimiter','-','token_length',4,'token_chars','0123456789','token_hex',false)
            % 
            % All inputs are optional, and use the seed passed (implicitly or explicitly) to 
            % the Haikunator constructor for randomization.
            %
            % Optional Inputs
            % ---------------
            % delimiter    : string to delimit the adjective noun and token
            %                defaults to '-'.
            % token_length : integer to specify the length of the token, 
            %                defaults to 4.
            % token_hex    : boolean, if true sets token_chars to 
            %                hexidecimal values '0123456789abcdef', will
            %                override anything passed to token_chars.
            %                Defaults to false.
            % token_chars  : string to serve as pool for token, defaults to
            %                '0123456789'.
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
            % h.haikunate('token_hex',true); % = 'lively-hill-6b04'
            %
            % % Change token_chars
            % h.haikunate('token_chars','HAIKUNATOR'); % 'lucky-king-UHNU'
            
            % Parse inputs
            ip = inputParser();
            addParameter(ip,'delimiter', [], @(x) ischar(x));
            addParameter(ip,'token_length', [], @(x) (isnumeric(x)  && (mod(x,1) == 0 || x == 0)));
            addParameter(ip,'token_hex', false, @(x) islogical(x));
            addParameter(ip,'token_chars', [], @(x) ischar(x));
            
            parse(ip, varargin{:});
            
            % Set name-type variables
            if isempty(ip.Results.delimiter)
                delimiter = obj.delimiter_;
            else
                delimiter = ip.Results.delimiter;
            end
            
            if isempty(ip.Results.token_length)
                token_length = obj.token_length_;
            else
                token_length = ip.Results.token_length;
            end
            
            if isempty(ip.Results.token_chars)
                token_chars = obj.token_chars_;
            else
                token_chars = ip.Results.token_chars;
            end
            
            if ip.Results.token_hex
                if ~isempty(ip.Results.token_chars)
                    warning(['token_chars were passed with token_hex=true.',...
                        'token_chars will be set to hexidecimal.'])
                end
                token_chars = '0123456789abcdef';
            end
            
            % Make name
            adjective = cell2mat(obj.getRandom(obj.adjectives,1));
            noun = cell2mat(obj.getRandom(obj.nouns,1));
            token = obj.getRandom(token_chars,token_length);
            
            % Account for zero token length
            if token_length == 0
                name = [adjective, delimiter, noun];    
            else
                name = [adjective, delimiter, noun, delimiter, token];
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