// Mecha paint gun. Used to set base and decal colours and to strip off decals. Also includes an unlimited supply of nanotrasen logos.
/obj/item/mecha_paint_gun
    name = "exosuit paint gun"
    desc = "An automated gun-shaped device used to apply or strip off paint and other decals, compatible with most standard exosuit models."
    icon = 'icons/obj/device.dmi'
    icon_state = "floor_painter"

    w_class = WEIGHT_CLASS_SMALL
    slot_flags = SLOT_BELT

    var/unlocked = FALSE
    var/obj/mecha/current_mecha

/obj/item/mecha_paint_gun/attack_obj(obj/O, mob/user)
    if(istype(O, /obj/mecha))
        openUI(O, user)
    else
        ..()

/obj/item/mecha_paint_gun/proc/openUI(obj/O, mob/user)
    current_mecha = O
    if(current_mecha.occupant)
        to_chat(user, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
        return
    if(!current_mecha.basecoat_icon)
        to_chat(user, "<span class='warning'>[src] is not compatible with this exosuit!</span>")
        return
    var/dat
    user.set_machine(src)
    if(!current_mecha)
        dat += "<b>No exosuit selected.</b><br/>"
    else
        dat += "<div class='paintGun'>"
        dat += "<font color='[current_mecha.basecoat_colour]'><b>Base Coat:</b></font> <A href='?src=[UID()];choice=set_base'>Set Colour</A> <A href='?src=[UID()];choice=default_base'>Default</A><br/>"
        dat += "<font color='[current_mecha.glow_colour]'><b>Glow:</b></font> <A href='?src=[UID()];choice=set_glow'>Set Colour</A> <A href='?src=[UID()];choice=default_glow'>Default</A><br/><br/>"
        if(current_mecha.decals.len != 0)
            dat += "<b>Current Decals:</b><br/>"
            for(var/obj/item/mecha_decal/decal in current_mecha.decals)
                if(decal.mutable_colour)
                    dat += "<font color='[decal.decal_colour]'>[decal.decal_name]:</font> <A href='?src=[UID()];decalcolour=\ref[decal]'>Colour</A> <A href='?src=[UID()];decalstrip=\ref[decal]'>Strip</A><br/>"
                else
                    dat += "[decal.decal_name]: <A href='?src=[UID()];decalstrip=\ref[decal]'>Strip</A><br/>"

        dat += "<b>Apply Decals:</b><br/>"
        dat += "<A href='?src=[UID()];choice=decal_nanotrasen'>Nanotrasen Logo</A><br/>"
        if(unlocked)
            dat += "<A href='?src=[UID()];choice=decal_syndicate'>Syndicate Logo</A><br/>"
        dat += "<br/><A href='?src=[UID()];choice=defaultdecals'>Default Decals</A> (Warning: will remove all current decals!)<br/>"

    dat += "<A href='?src=[UID()];refresh=1'>Refresh</A>"
    var/datum/browser/popup = new(user, "mechapaintgun", "<u>Exosuit Paint Gun:</u> [current_mecha]", 400, 350)
    popup.set_content(dat)
    popup.open()
    return

/obj/item/mecha_paint_gun/emag_act()
    unlocked = TRUE
    visible_message("[src] sparks briefly.")
    desc += "\n<span class='warning'>There seems to be a lot more black and red paint in the chamber than usual...</span>"

/obj/item/mecha_paint_gun/Topic(href, href_list, user)
    if(..())
        return 1
    if(!current_mecha.Adjacent(usr))
        return
    if(href_list["choice"])
        switch(href_list["choice"])
            if("set_base")
                current_mecha.basecoat_colour = input("Select the new base colour:", "Base Colour", current_mecha.basecoat_colour) as color|null
                if(current_mecha.Adjacent(usr))
                    visible_message("[src] covers the exosuit in a new coat of paint.")
                    playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                    openUI(current_mecha, usr)
            if("set_glow")
                if(current_mecha.Adjacent(usr))
                    current_mecha.glow_colour = input("Select the new glow colour:", "Glow Colour", current_mecha.glow_colour) as color|null
                    visible_message("[src] covers the exosuit in a new coat of paint.")
                    playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                    openUI(current_mecha, usr)
            if("default_base")
                if(current_mecha.Adjacent(usr))
                    current_mecha.basecoat_colour = initial(current_mecha.basecoat_colour)
                    visible_message("[src] covers the exosuit in a new coat of paint.")
                    playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                    openUI(current_mecha, usr)
            if("default_glow")
                if(current_mecha.Adjacent(usr))
                    current_mecha.glow_colour = initial(current_mecha.glow_colour)
                    visible_message("[src] covers the exosuit in a new coat of paint.")
                    playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                    openUI(current_mecha, usr)
            if("decal_nanotrasen")
                if(current_mecha.Adjacent(usr))
                    if(!current_mecha.add_decal(new/obj/item/mecha_decal/nanotrasen_logo))
                        visible_message("[src]'s fine sprayers neatly trace a logo on the exosuit.")
                        playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                        openUI(current_mecha, usr)
            if("decal_syndicate")
                if(current_mecha.Adjacent(usr))
                    if(!current_mecha.add_decal(new/obj/item/mecha_decal/syndicate_logo))
                        visible_message("[src]'s fine sprayers leave a glistening red symbol on the exosuit.")
                        playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                        openUI(current_mecha, usr)
            if("defaultdecals")
                if(current_mecha.Adjacent(usr))
                    current_mecha.decals = current_mecha.default_decals
                    visible_message("[src] strips all the decals off [current_mecha] and returns it to factory standard.")
                    playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                    openUI(current_mecha, usr)
    
    if(href_list["decalcolour"])
        if(current_mecha.Adjacent(usr))
            var/hrefstring = href_list["decalcolour"]
            var/obj/item/mecha_decal/D = locate(hrefstring)
            D.decal_colour = input("Select the new decal colour:", "Decal Colour", D.decal_colour) as color|null
            visible_message("[src] carefully paints over the decal.")
            playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
            openUI(current_mecha, usr)

    if(href_list["decalstrip"])
        if(current_mecha.Adjacent(usr))
            var/hrefstring = href_list["decalstrip"]
            var/obj/item/mecha_decal/D = locate(hrefstring)
            current_mecha.decals.Remove(D)
            qdel(D)
            visible_message("[src] carefully strips off the decal.")
            playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
            openUI(current_mecha, usr)

    current_mecha.update_icon()

// Containers for mecha decals. Each one is a physical object which is contained in a list within the mecha when added.
// Each mecha has a decal root string of the form "[mech_name]-decal" which is used to fetch and apply the decal icon.
// There is no governance as to which decals can be applied in which order.
/obj/item/mecha_decal
    name = "exosuit decal kit"
    desc = "A set of stickers and paints with no real purpose. You shouldn't be seeing this."
    icon = 'icons/obj/module.dmi'
    icon_state = "harddisk_mini"

    var/decal_string                        // The string which is added to the mech's decal_root in order to apply the icon. 
    var/decal_name                          // The name shown by the decal UI.
    var/mutable_colour = FALSE              // Whether the colour can be set. Off for things with a set colour, like the nanotrasen logo.
    var/glowing = FALSE                     // Determines the layer the overlays are placed on. Will shine in the dark if true.
    var/decal_layer = 1                     // The higher the decal layer, the less things will cover it.
    var/decal_colour = "#000000"            // If the colour can be set, it is read from here when determining overlays.
    var/list/obj/mecha/compatible_mecha     // Which mech types the kit can be applied to.

/obj/item/mecha_decal/attack_obj(obj/O, mob/living/user)
    if(istype(O, /obj/mecha))
        var/obj/mecha/M = O
        if(M.type in compatible_mecha)
            if(M.add_decal(src))
                playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
                to_chat(user, "<span class='notice'>You apply [src] to [M].</span>")
                user.drop_item()
                src.loc = null
            else
                to_chat(user, "<span class='warning'>[M] already has [src] applied!</span>")
        else
            to_chat(user, "<span class='warning'>[src] is not compatible with [M]!</span>")
        return
    ..()

/obj/item/mecha_decal/proc/colour_decal(var/colour)
    decal_colour = colour

// For decals which add multiple layers. All decals contained within are added to the mech at once in sequential order.
/obj/item/compound_mecha_decal
    name = "exosuit complex decal kit"
    desc = "An elaborate set of stickers and paints with no real purpose. You shouldn't be seeing this."
    icon = 'icons/obj/module.dmi'
    icon_state = "harddisk_mini"

    var/list/obj/item/mecha_decal/decals
    var/list/obj/mecha/compatible_mecha  

/obj/item/compound_mecha_decal/attack_obj(obj/O, mob/living/user)
    if(istype(O, /obj/mecha))
        var/obj/mecha/M = O
        if(decals && (M.type in compatible_mecha))
            for(var/obj/item/mecha_decal/decal in decals)
                M.add_decal(decal)
            playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
            to_chat(user, "<span class='notice'>You apply [src] to [M].</span>")
            qdel(src)
        else
            to_chat(user, "<span class='warning'>[src] is not compatible with [M]!</span>")
        return
    ..()

///////////////////////
// Decal Definitions //
///////////////////////

/obj/item/mecha_decal/stripes
    name = "exosuit decal kit (Racing Stripes)"
    desc = "A set of stickers and paints to apply racing stripes to your exosuit. Widely compatible with most standard mech types."
    decal_string = "stripes"
    decal_name = "Racing Stripes"
    mutable_colour = TRUE
    decal_colour = "#A00000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/nanotrasen_logo
    name = "exosuit decal kit (Nanotrasen Logo)"
    desc = "Corporate approved!"
    decal_string = "nt_logo"
    decal_name = "Nanotrasen Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/syndicate_logo
    name = "exosuit decal kit (Syndicate Logo)"
    desc = "Goes best with black."
    decal_string = "syn_logo"
    decal_name = "Syndicate Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/titan
    name = "exosuit decal kit (Ripley Titan Skull)"
    desc = "A spooky skull and white paint for the APLU models."
    decal_string = "titan"
    decal_name = "Titan Skull"
    mutable_colour = FALSE
    decal_layer = 3
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/titaneyes
    name = "exosuit decal kit (Ripley Titan Eyes)"
    desc = "Glowing lights for the skull's eyes. Spookier!"
    decal_string = "titaneyes"
    decal_name = "Titan Eyes"
    mutable_colour = TRUE
    glowing = TRUE
    decal_layer = 4
    decal_colour = "#00AB00"
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

// Testing for complex decal
/obj/item/compound_mecha_decal/nanotrasen_and_stripes
    name = "exosuit complex decal kit (Logo and Stripes)"
    desc = "An elaborate set of stickers and paints. Widely compatible with most standard mech types."
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/compound_mecha_decal/nanotrasen_and_stripes/Initialize()
    var/obj/item/mecha_decal/S = new/obj/item/mecha_decal/stripes
    S.decal_colour = "#5e84ab"
    var/obj/item/mecha_decal/L = new/obj/item/mecha_decal/nanotrasen_logo
    L.glowing = TRUE
    decals = list(S,L)

// Replacement for titan paintkit.
/obj/item/compound_mecha_decal/titan
    name = "exosuit complex decal kit (Ripley Titan)"
    desc = "A giant skull and a bunch of white paint made to fit a Ripley exosuit frame. Spooky!"
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/compound_mecha_decal/titan/Initialize()
    decals = list(new/obj/item/mecha_decal/titan, new/obj/item/mecha_decal/titaneyes)



