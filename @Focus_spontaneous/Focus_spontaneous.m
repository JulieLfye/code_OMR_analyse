classdef Focus_spontaneous < handle
   
    properties
        
        dpf
        
        Root
        
    end
    
    methods
       
        function this = Focus_spontaneous() 
            
            switch computer
                case 'PCWIN64'
                    this.Root = 'D:\OMR_acoustic_experiments\data\';
            end
            
        end
        
        % -----------------------------------------------------------------
        
        function p = path(this)
           
            p = [this.Root this.dpf filesep];
            
        end
        
        % -----------------------------------------------------------------
        
        function D = load(this, filename)
           
            D = load([this.path() filename]);
            
        end
    end
    
end