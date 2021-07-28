# Knockback Modifier

Custom Attribute using Nosoop's [custom attributes framework](https://github.com/nosoop/SM-TFCustAttr). 
This plugin lets you change the knockback of a weapon.

[Alliedmodders post](https://forums.alliedmods.net/showthread.php?t=333657).

## How to apply the attribute

`"knockback modifier" 	"value"`

Shove it inside tf_custom_attributes.txt if you want to replace a normal weapon's model ( or anything else that supports custom attributes ) or in the Custom Attribuets section inside a custom weapon's cfg if you use Custom Weapons X.

**value**: 1.0 is the default knockback. 0.5 would be half of the original knockback and 1.5 would be 50% more knockback. You can change it as much as you want, even remove it by putting 0.0.

Example: `0.4` ( 60% less knockback )

## Dependencies

[Dhooks](https://github.com/peace-maker/DHooks2)

[Custom Attributes Framework](https://github.com/nosoop/SM-TFCustAttr)

[TF2 Attributes](https://github.com/nosoop/tf2attributes)

You might need [this dependency as well](https://github.com/nosoop/stocksoup) if you want to compile it yourself.

## Other info

This plugin uses Nosoop's [Ninja](https://github.com/nosoop/NinjaBuild-SMPlugin) template. Easy to organize everything and build releases. I'd recommend to check it out.

#

Please, this is the first version of this plugin. If you find any issues, make sure to open an issue to let me know!

Also I've got no clue how to properly format this.
