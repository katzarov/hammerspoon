# Hammerspoon

My hammerspoon config - trying to achieve some keyboard remapping and layering only by using hammerspoon and/or mac os settings.

It's not the best tool for the job but I have a few reasons for trying it.

Otherwise, I'd go straight for Kanata + Karabiner driver. Which I might still do at some point, as I don't want to implement home row mods in hammerspoon.

## Permanent key remapping

- can remap some modifier keys on mac os settings
- and again mac os native - hidutil https://github.com/Hammerspoon/hammerspoon/issues/3512#issuecomment-1661977782
- I would not use HS for permanents key remappings... unless im already watching for all keystrokes anyway - then i guess its whatever.

I will try the angle mod I think it is called... On iso keyboard you can remap z-b row of keys to \`-v and then b to \`
So on your left hand you just shift all keys on that row a bit to the left which makes the annoying jump go away, and your fingers can just curl like they do on the right hand.

## The layer trigger key

Lots of different approaches:

1. make caps lock a hyperkey - when held down it will be as if all modifier keys are held down at the same time and ofc there are no current hotkey bindings for it so whatever you put on that layer wont clash with anything. Requires extra software - like HyperKey, BTT, or Karabiner idk.
2. make caps lock an unused key like f18 - can use MAC OS's hidutil for this - should be a good solution. But f18 is not a modifier key. You would need to watch all keystrokes.
3. make caps lock the FN key - can be done from the settings. For me this would work well since i never used the FN key before. I will override whatever shortucts it has and that is fine for me. E.g. in my layer i have fn + f => "[". Originally fn + f makes an app fulscreen which now I will lose, and will instad produce the "[" character. And in this case we don't need to watch for all keystrokes, but we only watch for when certain mod key = fn, is pressed and only then do we strat watching all keystrokes. I based my code on this - https://github.com/Hammerspoon/hammerspoon/issues/3512#issuecomment-1629690255
4. pretty much like 2) - we will need to watch for all keystrokes, but we can make the layer trigger key more ergonomic.. we can use spacebar. This will pose some challenges but lets see how it works. Biggest drawback is that the space will be emitted on key up and not key down...

## Extra things i did not dive into

- Making a custom keyboard layout - Ukelele, Keyboard Maestro ? And maybe just swith to it when out trigger key is held ?

## Challenges with approach #4

- need to handle rolling - when we type fast the following is likely to happen:
  1. "a" keydown -> "space" keydown -> "a" keyup -> "space" keyup = we need to produce an "a" and a "space"
  2. "space" keydown -> "a" keydown -> "space" keyup -> "a" keyup = we need to produce a "space" and an "a"

1. is trivial to handle
2. requires some thought. We need to introduce a timer and dtermine if the users intention is to just type in normal mode or trigger the layer.

- so we can: Upon inital space down block that space and wait for the timer. If the user types a word within the timer then that would be a normal word so we need to emit the prebiously blocked space and the character. If the user types a word after the timer has elapsed then we assume user wishes to activate the second layer. Unless ofc user releases space.
- we also can: Do the same as before but dont block the initial space down. Produce that space anyway and if user types another char wihting the timer we are good. If the user waits for the timer and then produces some characted then our assumption was icorrect so we need to rollback the space, i.e. delete it. I call this the optimistic approach. Not sure if i like it.. might be unsafe. It does have one extra positive though - it shows the sure when the layer is active, but i can achieve this antherway with hammerspoon anyway. If i even want that. But yeah imagine if we are in some app where the space means enter/submit/continiue.. could be a potential scenraio and we cannot rollback that.

