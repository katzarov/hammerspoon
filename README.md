# Hammerspoon

My hammerspoon config - trying to achieve some keyboard remapping and layering only by using hammerspoon and/or mac os settings.

It's not the best tool for the job but I have a few reasons for trying it.

Otherwise, I'd go straight for Kanata + Karabiner driver. Which I might still do at some point, as I don't want to implement home row mods in hammerspoon.

## Permanent key remapping

- can remap some modifier keys on mac os settings
- and again mac os native - hiduitls https://github.com/Hammerspoon/hammerspoon/issues/3512#issuecomment-1661977782
- I would not use HS for permanents key remappings... unless im already watching for all keystrokes anyway - then i guess its whatever.

I will try the angle mod I think it is called... On iso keyboard you can remap z-b row of keys to \`-v and then b to \`
So on your left hand you just shift all keys on that row a bit to the left which makes the annoying jump go away, and your fingers can just curl like they do on the right hand.

## The layer trigger key

Lots of different approaches:

1. make caps lock a hyperkey - when held down it will be as if all modifier keys are held down at the same time and ofc there are no current hotkey bindings for it so whatever you put on that layer wont clash with anything. Requires extra software - like HyperKey, BTT, or Karabiner idk.
2. make caps lock an unused key like f18 - can use MAC OS's hiduitls for this - should be a good solution. But f18 is not a modifier key. You would need to watch all keystrokes.
3. make caps lock the FN key - can be done from the settings. For me this would work well since i never used the FN key before. I will override whatever shortucts it has and that is fine for me. E.g. in my layer i have fn + f => "[". Originally fn + f makes an app fulscreen which now I will lose, and will instad produce the "[" character. And in this case we don't need to watch for all keystrokes, but we only watch for when certain mod key = fn, is pressed and only then do we strat watching all keystrokes. I based my code on this - https://github.com/Hammerspoon/hammerspoon/issues/3512#issuecomment-1629690255
4. pretty much like 2) - we will need to watch for all keystrokes, but we can make the layer trigger key more ergonomic.. we can use spacebar. This will pose some challenges but lets see how it works. Biggest drawback is that the space will be emitted on key up and not key down...

## Extra things i did not dive into

- Making a custom keyboard layout - Ukelele, Keyboard Maestro ? And maybe just swith to it when out trigger key is held ?

