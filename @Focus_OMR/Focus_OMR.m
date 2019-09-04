classdef Focus_OMR < handle
   
    properties
        
        cycle
        speed
        dpf
        
        Root
        
    end
    
    methods
       
        function this = Focus_OMR() 
            
            switch computer
                case 'PCWIN64'
                    this.Root = 'D:\OMR_acoustic_experiments\data\';
            end
            
        end
        
        % -----------------------------------------------------------------
        
        function p = path(this)
           
            p = [this.Root filesep this.dpf filesep this.cycle filesep this.speed filesep];
            
        end
        
        % -----------------------------------------------------------------
        
        function D = load(this, filename)
           
            D = load([this.path() filename]);
            
        end
    end
    
end