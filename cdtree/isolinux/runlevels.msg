
 We are supporting a number of boot options, identified  by 

 - the level (such as "r2" - I made this short to avoid a lot of typing) 
 - a 32 or 64bit system (add -64 for a 64 system (default 32) 
 - framebuffer support or not ( add -nofb, default is to boot with fb support)

 Examples:

 "r2"         means run level 2, frambuffer enabled,  32bit system
 "r2-nofb"    means run level 2, frambuffer disabled, 32bit system
 "r2-64"      means run level 2, frambuffer enabled,  64bit system
 "r2-64-nofb" means run level 2, frambuffer disabled, 64bit system

 analogous for the other run levels. 

 "r1" is the most fail-safe option if nothing else goes.

