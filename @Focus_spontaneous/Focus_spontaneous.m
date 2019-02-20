classdef Focus_spontaneous < handle
   
    properties
        
        date
        
        Root
        
    end
    
    methods
       
        function this = Focus_spontaneous() 
            
            switch computer
                case 'PCWIN64'
                    this.Root = 'C:\Users\LJP\Documents\MATLAB\these\data_spontaneous\data\';
            end
            
        end
        
        % -----------------------------------------------------------------
        
        function p = path(this)
           
            p = [this.Root this.date filesep];
            
        end
        
        % -----------------------------------------------------------------
        
        function D = load(this, filename)
           
            D = load([this.path() filename]);
            
        end
    end
    
end