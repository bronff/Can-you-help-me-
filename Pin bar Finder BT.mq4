/ / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                               P i n   B a r   F i n d e r . m q 4   |  
 / / |                                                 C o p y r i g h t   2 0 1 3 ,   M e t a Q u o t e s   S o f t w a r e   C o r p .   |  
 / / |                                                                                 h t t p : / / w w w . m e t a q u o t e s . n e t   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # p r o p e r t y   c o p y r i g h t   " C o p y r i g h t   2 0 1 3 ,   M e t a Q u o t e s   S o f t w a r e   C o r p . "  
 # p r o p e r t y   l i n k             " h t t p : / / w w w . m e t a q u o t e s . n e t "  
 # p r o p e r t y   i n d i c a t o r _ c h a r t _ w i n d o w  
 # p r o p e r t y   i n d i c a t o r _ b u f f e r s   6  
 # p r o p e r t y   i n d i c a t o r _ c o l o r 1   R e d                   / /   B e a r   P i n b a r  
 # p r o p e r t y   i n d i c a t o r _ c o l o r 2   G r e e n               / /   B u l l   P i n b a r  
 # p r o p e r t y   i n d i c a t o r _ c o l o r 3   R e d                   / /   I n s i d e   b a r s   - -   u p p e r   w i c k  
 # p r o p e r t y   i n d i c a t o r _ c o l o r 4   R e d                   / /   I n s i d e   b a r s   - -   l o w e r   w i c k  
  
 e x t e r n   b o o l   p i n b a r _ o n   =   t r u e ;  
 e x t e r n   b o o l   i n s i d e b a r _ o n   =   f a l s e ;  
 e x t e r n   i n t   h i g h l i g h t _ w i d t h   =   5 ;  
 e x t e r n   c o l o r   i n s i d e b a r _ c l r   =   Y e l l o w ;  
 e x t e r n   d o u b l e   b o d y 2 p i n _ r a t i o   =   2 . 0 ;  
 e x t e r n   i n t   p e r i o d   =   2 0 ;   / /   D e f i n e   p e r i o d   f o r   u s e   i n   g e t _ m a x   a n d   g e t _ m i n  
  
 e x t e r n   s t r i n g                           b u t t o n _ n o t e 1                     =   " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " ;  
 e x t e r n   i n t                                 b t n _ S u b w i n d o w   =   0 ;  
 e x t e r n   E N U M _ B A S E _ C O R N E R       b t n _ c o r n e r                         =   C O R N E R _ L E F T _ U P P E R ;    
 e x t e r n   s t r i n g                           b t n _ t e x t                             =   " F i n d e r " ;  
 e x t e r n   s t r i n g                           b t n _ F o n t                             =   " A r i a l " ;  
 e x t e r n   i n t                                 b t n _ F o n t S i z e                     =   1 0 ;                                                          
 e x t e r n   c o l o r                             b t n _ t e x t _ O N _ c o l o r           =   c l r L i m e ;  
 e x t e r n   c o l o r                             b t n _ t e x t _ O F F _ c o l o r         =   c l r R e d ;  
 e x t e r n   s t r i n g                           b t n _ p r e s s e d                       =   " P i n b a r   O N " ;                          
 e x t e r n   s t r i n g                           b t n _ u n p r e s s e d                   =   " P i n b a r   O F F " ;  
 e x t e r n   c o l o r                             b t n _ b a c k g r o u n d _ c o l o r     =   c l r D i m G r a y ;  
 e x t e r n   c o l o r                             b t n _ b o r d e r _ c o l o r             =   c l r B l a c k ;  
 e x t e r n   i n t                                 b u t t o n _ x                             =   1 3 7 5 ;                                                                    
 e x t e r n   i n t                                 b u t t o n _ y                             =   2 0 ;                                                                        
 e x t e r n   i n t                                 b t n _ W i d t h                           =   1 1 0 ;                                                                    
 e x t e r n   i n t                                 b t n _ H e i g h t                         =   2 2 ;                                                                  
 e x t e r n   s t r i n g                           s o u n d B T                               =   " t i c k . w a v " ;      
 e x t e r n   s t r i n g                           b u t t o n _ n o t e 2                     =   " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " ;  
  
 b o o l                                             s h o w _ d a t a                           =   t r u e ;  
 s t r i n g   I n d i c a t o r N a m e ,   I n d i c a t o r O b j P r e f i x ,   b u t t o n I d ;  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   G l o b a l   v a r i a b l e s                                                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 d o u b l e   I n s i d e b a r U p p e r B u f f e r [ ] ;  
 d o u b l e   I n s i d e b a r L o w e r B u f f e r [ ] ;  
 d o u b l e   M o t h e r b a r U p p e r B u f f e r [ ] ;  
 d o u b l e   M o t h e r b a r L o w e r B u f f e r [ ] ;  
 d o u b l e   P i n b a r B e a r B u f f e r [ ] ;  
 d o u b l e   P i n b a r B u l l B u f f e r [ ] ;  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   I n d i c a t o r   I n i t i a l i z a t i o n   F u n c t i o n                                                                 |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n I n i t ( )   {  
         I n d i c a t o r B u f f e r s ( 6 ) ;  
         S e t I n d e x B u f f e r ( 0 ,   P i n b a r B u l l B u f f e r ) ;  
         S e t I n d e x S t y l e ( 0 ,   D R A W _ A R R O W ) ;  
         S e t I n d e x A r r o w ( 0 ,   2 1 7 ) ;  
         S e t I n d e x E m p t y V a l u e ( 0 ,   0 . 0 ) ;  
  
         S e t I n d e x B u f f e r ( 1 ,   P i n b a r B e a r B u f f e r ) ;  
         S e t I n d e x S t y l e ( 1 ,   D R A W _ A R R O W ) ;  
         S e t I n d e x A r r o w ( 1 ,   2 1 8 ) ;  
         S e t I n d e x E m p t y V a l u e ( 1 ,   0 . 0 ) ;  
  
         S e t I n d e x B u f f e r ( 2 ,   I n s i d e b a r L o w e r B u f f e r ) ;  
         S e t I n d e x S t y l e ( 2 ,   D R A W _ H I S T O G R A M ) ;  
         S e t I n d e x E m p t y V a l u e ( 2 ,   0 . 0 ) ;  
  
         S e t I n d e x B u f f e r ( 3 ,   I n s i d e b a r U p p e r B u f f e r ) ;  
         S e t I n d e x S t y l e ( 3 ,   D R A W _ H I S T O G R A M ) ;  
         S e t I n d e x E m p t y V a l u e ( 3 ,   0 . 0 ) ;  
  
         S e t I n d e x B u f f e r ( 4 ,   M o t h e r b a r L o w e r B u f f e r ) ;  
         S e t I n d e x S t y l e ( 4 ,   D R A W _ H I S T O G R A M ) ;  
         S e t I n d e x E m p t y V a l u e ( 4 ,   0 . 0 ) ;  
  
         S e t I n d e x B u f f e r ( 5 ,   M o t h e r b a r U p p e r B u f f e r ) ;  
         S e t I n d e x S t y l e ( 5 ,   D R A W _ H I S T O G R A M ) ;  
         S e t I n d e x E m p t y V a l u e ( 5 ,   0 . 0 ) ;  
  
         / /   I n i t i a l i z e   b u t t o n  
         I n d i c a t o r N a m e   =   G e n e r a t e I n d i c a t o r N a m e ( b t n _ t e x t ) ;  
         I n d i c a t o r O b j P r e f i x   =   " _ _ "   +   I n d i c a t o r N a m e   +   " _ _ " ;  
         b u t t o n I d   =   I n d i c a t o r O b j P r e f i x   +   b t n _ t e x t ;  
         c r e a t e B u t t o n ( b u t t o n I d ,   b t n _ t e x t ,   b t n _ W i d t h ,   b t n _ H e i g h t ,   b t n _ F o n t ,   b t n _ F o n t S i z e ,   b t n _ b a c k g r o u n d _ c o l o r ,   b t n _ b o r d e r _ c o l o r ,   b t n _ t e x t _ O N _ c o l o r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ Y D I S T A N C E ,   b u t t o n _ y ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ X D I S T A N C E ,   b u t t o n _ x ) ;  
  
         d o u b l e   v a l ;  
         i f   ( G l o b a l V a r i a b l e G e t ( I n d i c a t o r N a m e   +   " _ v i s i b i l i t y " ,   v a l ) )  
                 s h o w _ d a t a   =   v a l   ! =   0 ;  
  
         C h a r t S e t I n t e g e r ( C h a r t I D ( ) ,   C H A R T _ E V E N T _ M O U S E _ M O V E ,   1 ) ;  
         b u t t o n I d   =   I n d i c a t o r O b j P r e f i x + b t n _ t e x t ;  
         c r e a t e B u t t o n ( b u t t o n I d ,   b t n _ t e x t ,   b t n _ W i d t h ,   b t n _ H e i g h t ,   b t n _ F o n t ,   b t n _ F o n t S i z e ,   b t n _ b a c k g r o u n d _ c o l o r ,   b t n _ b o r d e r _ c o l o r ,   b t n _ t e x t _ O N _ c o l o r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ Y D I S T A N C E ,   b u t t o n _ y ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ X D I S T A N C E ,   b u t t o n _ x ) ;  
  
         r e t u r n   I N I T _ S U C C E E D E D ;  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C u s t o m   I n d i c a t o r   D e i n i t i a l i z a t i o n   F u n c t i o n                                               |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
       v o i d   O n D e i n i t ( c o n s t   i n t   r e a s o n )  
     {  
       O b j e c t s D e l e t e A l l ( 0 , " P i n b a r " ) ;  
       O b j e c t s D e l e t e A l l ( C h a r t I D ( ) ,   I n d i c a t o r O b j P r e f i x ) ;  
        
 }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C u s t o m   I n d i c a t o r   C a l c u l a t i o n   F u n c t i o n                                                         |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n C a l c u l a t e ( c o n s t   i n t   r a t e s _ t o t a l ,   c o n s t   i n t   p r e v _ c a l c u l a t e d ,   c o n s t   d a t e t i m e &   t i m e [ ] ,  
                                 c o n s t   d o u b l e &   o p e n [ ] ,   c o n s t   d o u b l e &   h i g h [ ] ,   c o n s t   d o u b l e &   l o w [ ] ,   c o n s t   d o u b l e &   c l o s e [ ] ,  
                                 c o n s t   l o n g &   t i c k _ v o l u m e [ ] ,   c o n s t   l o n g &   v o l u m e [ ] ,   c o n s t   i n t &   s p r e a d [ ] )   {  
         i n t   l i m i t   =   r a t e s _ t o t a l   -   p r e v _ c a l c u l a t e d   -   1 ;  
          
         i f   ( s h o w _ d a t a )   {  
                 f o r   ( i n t   i   =   0 ;   i   <   l i m i t ;   i + + )   {  
                         i f   ( p i n b a r _ o n )   c h e c k _ p i n b a r ( i   +   1 ,   h i g h ,   l o w ,   o p e n ,   c l o s e ) ;  
                         i f   ( i n s i d e b a r _ o n )   c h e c k _ i n s i d e b a r ( i   +   1 ,   h i g h ,   l o w ) ;  
                 }  
         }   e l s e   {  
                 / /   C l e a r   t h e   b u f f e r s   i f   s h o w _ d a t a   i s   f a l s e  
                 A r r a y I n i t i a l i z e ( P i n b a r B u l l B u f f e r ,   0 . 0 ) ;  
                 A r r a y I n i t i a l i z e ( P i n b a r B e a r B u f f e r ,   0 . 0 ) ;  
                 A r r a y I n i t i a l i z e ( I n s i d e b a r L o w e r B u f f e r ,   0 . 0 ) ;  
                 A r r a y I n i t i a l i z e ( I n s i d e b a r U p p e r B u f f e r ,   0 . 0 ) ;  
                 A r r a y I n i t i a l i z e ( M o t h e r b a r L o w e r B u f f e r ,   0 . 0 ) ;  
                 A r r a y I n i t i a l i z e ( M o t h e r b a r U p p e r B u f f e r ,   0 . 0 ) ;  
         }  
  
         r e t u r n   r a t e s _ t o t a l ;  
 }  
  
 v o i d   c h e c k _ i n s i d e b a r ( i n t   i n d ,   c o n s t   d o u b l e &   h i g h [ ] ,   c o n s t   d o u b l e &   l o w [ ] ) {  
       b o o l   w i t h i n _ n e i g h b o r _ r a n g e   =   h i g h [ i n d + 1 ]   >   h i g h [ i n d ]   & &   l o w [ i n d + 1 ]   <   l o w [ i n d ] ;  
       i f (   w i t h i n _ n e i g h b o r _ r a n g e   ) {  
             M o t h e r b a r L o w e r B u f f e r [ i n d + 1 ] = l o w [ i n d + 1 ] ;              
             M o t h e r b a r U p p e r B u f f e r [ i n d + 1 ] = h i g h [ i n d + 1 ] ;            
              
             I n s i d e b a r L o w e r B u f f e r [ i n d ] = l o w [ i n d ] ;  
             I n s i d e b a r U p p e r B u f f e r [ i n d ] = h i g h [ i n d ] ;             / /   I n d i c a t e   t h e   i n s i d e   b a r   +   M o t h e r   b a r  
       }  
 }  
  
 v o i d   c h e c k _ p i n b a r ( i n t   i n d ,   c o n s t   d o u b l e &   h i g h [ ] ,   c o n s t   d o u b l e &   l o w [ ] ,   c o n s t   d o u b l e &   o p e n [ ] ,   c o n s t   d o u b l e &   c l o s e [ ] ) {  
       d o u b l e   p i n ,   b o d y ;  
       d o u b l e   n e i g h b o r 1 _ H ,   n e i g h b o r 1 _ L ;  
       b o o l   b o d y _ w i t h i n _ n e i g h b o r _ r a n g e ;  
       b o o l   p i n _ b e y o n d _ n e i g h b o r _ r a n g e ;  
        
       n e i g h b o r 1 _ H   =   h i g h [ i n d + 1 ] ;  
       n e i g h b o r 1 _ L   =   l o w [ i n d + 1 ] ;  
       b o d y _ w i t h i n _ n e i g h b o r _ r a n g e   =   M a t h M a x ( o p e n [ i n d ] ,   c l o s e [ i n d ] )   <   n e i g h b o r 1 _ H   & &   M a t h M i n ( o p e n [ i n d ] ,   c l o s e [ i n d ] )   >   n e i g h b o r 1 _ L ;  
        
       / /   C h e c k   t h e   b u l l i s h   p i n b a r  
       p i n   =   M a t h M i n ( o p e n [ i n d ] ,   c l o s e [ i n d ] ) - l o w [ i n d ] ;  
       b o d y   =   h i g h [ i n d ] - l o w [ i n d ] - p i n ;  
       p i n _ b e y o n d _ n e i g h b o r _ r a n g e   =   l o w [ i n d ]   <   l o w [ i n d + 1 ] ;  
       i f   ( p i n   >   b o d y 2 p i n _ r a t i o * b o d y   & &   b o d y _ w i t h i n _ n e i g h b o r _ r a n g e   & &   p i n _ b e y o n d _ n e i g h b o r _ r a n g e )   {  
             P i n b a r B u l l B u f f e r [ i n d ]   =   l o w [ i n d ] ;  
       }  
  
       / /   C h e c k   t h e   b e a r i s h   p i n b a r  
       p i n   =   h i g h [ i n d ] - M a t h M a x ( o p e n [ i n d ] ,   c l o s e [ i n d ] ) ;  
       b o d y   =   h i g h [ i n d ] - l o w [ i n d ] - p i n ;  
       p i n _ b e y o n d _ n e i g h b o r _ r a n g e   =   h i g h [ i n d ]   >   h i g h [ i n d + 1 ] ;  
       i f   ( p i n   >   b o d y 2 p i n _ r a t i o * b o d y   & &   b o d y _ w i t h i n _ n e i g h b o r _ r a n g e   & &   p i n _ b e y o n d _ n e i g h b o r _ r a n g e ) {  
             P i n b a r B e a r B u f f e r [ i n d ]   =   h i g h [ i n d ] ;  
       }  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C h a r t   e v e n t   h a n d l e r                                                                                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n C h a r t E v e n t ( c o n s t   i n t   i d ,   c o n s t   l o n g   & l p a r a m ,   c o n s t   d o u b l e   & d p a r a m ,   c o n s t   s t r i n g   & s p a r a m )   {  
         h a n d l e B u t t o n C l i c k s ( ) ;  
         i f   ( i d   = =   C H A R T E V E N T _ O B J E C T _ C L I C K   & &   O b j e c t G e t ( s p a r a m ,   O B J P R O P _ T Y P E )   = =   O B J _ B U T T O N )   {  
                 i f   ( s o u n d B T   ! =   " " )   P l a y S o u n d ( s o u n d B T ) ;  
         }  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   H e l p e r   f u n c t i o n s                                                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 s t r i n g   G e n e r a t e I n d i c a t o r N a m e ( c o n s t   s t r i n g   t a r g e t )   {  
         s t r i n g   n a m e   =   t a r g e t ;  
         i n t   t r y   =   2 ;  
         w h i l e   ( W i n d o w F i n d ( n a m e )   ! =   - 1 )   {  
                 n a m e   =   t a r g e t   +   "   # "   +   I n t e g e r T o S t r i n g ( t r y + + ) ;  
         }  
         r e t u r n   n a m e ;  
 }  
  
 v o i d   c r e a t e B u t t o n ( s t r i n g   b u t t o n I D ,   s t r i n g   b u t t o n T e x t ,   i n t   w i d t h ,   i n t   h e i g h t ,   s t r i n g   f o n t ,   i n t   f o n t S i z e ,   c o l o r   b g C o l o r ,   c o l o r   b o r d e r C o l o r ,   c o l o r   t x t C o l o r )   {  
         O b j e c t D e l e t e ( C h a r t I D ( ) ,   b u t t o n I D ) ;  
         O b j e c t C r e a t e ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J _ B U T T O N ,   b t n _ S u b w i n d o w ,   0 ,   0 ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ C O L O R ,   t x t C o l o r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ B G C O L O R ,   b g C o l o r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ B O R D E R _ C O L O R ,   b o r d e r C o l o r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ X S I Z E ,   w i d t h ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ Y S I Z E ,   h e i g h t ) ;  
         O b j e c t S e t S t r i n g ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ F O N T ,   f o n t ) ;  
         O b j e c t S e t S t r i n g ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ T E X T ,   b u t t o n T e x t ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ F O N T S I Z E ,   f o n t S i z e ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ S E L E C T A B L E ,   0 ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ C O R N E R ,   b t n _ c o r n e r ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ H I D D E N ,   1 ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ X D I S T A N C E ,   9 9 9 9 ) ;  
         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I D ,   O B J P R O P _ Y D I S T A N C E ,   9 9 9 9 ) ;  
 }  
  
 v o i d   h a n d l e B u t t o n C l i c k s ( )   {  
         i f   ( O b j e c t G e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ S T A T E ) )   {  
                 O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ S T A T E ,   f a l s e ) ;  
                 s h o w _ d a t a   =   ! s h o w _ d a t a ;  
                 G l o b a l V a r i a b l e S e t ( I n d i c a t o r N a m e   +   " _ v i s i b i l i t y " ,   s h o w _ d a t a   ?   1 . 0   :   0 . 0 ) ;  
                  
                 i f   ( s h o w _ d a t a )   {  
                         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ C O L O R ,   b t n _ t e x t _ O F F _ c o l o r ) ;  
                         O b j e c t S e t S t r i n g ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ T E X T ,   b t n _ u n p r e s s e d ) ;  
                 }   e l s e   {  
                         O b j e c t S e t I n t e g e r ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ C O L O R ,   b t n _ t e x t _ O N _ c o l o r ) ;  
                         O b j e c t S e t S t r i n g ( C h a r t I D ( ) ,   b u t t o n I d ,   O B J P R O P _ T E X T ,   b t n _ p r e s s e d ) ;  
                 }  
         }  
 }  
 