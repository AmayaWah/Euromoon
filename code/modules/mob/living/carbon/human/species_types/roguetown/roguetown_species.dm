/datum/species
	var/amtfail = 0

/datum/species/proc/get_accent_list(mob/living/carbon/human/H, type)
	switch(H.char_accent)
		if("No accent")
			return
		if("Stonespirit accent")
			return strings("dwarfcleaner_replacement.json", "dwarf")
		if("Dwarf Gibberish accent")
			return strings("dwarf_replacement.json", "dwarf_gibberish")
		if("Roseveilian accent")
			return strings("french_replacement.json", "french")
		if("Timberwolf accent")
			return strings("russian_replacement.json", "russian")
		if("Greenlyre accent")
			return strings("german_replacement.json", "german")
		if("Northerner accent")
			return strings("Anglish.json", "Anglish")
		if("Celestian accent")
			return strings("proper_replacement.json", "proper")
		if("Lizard accent")
			return strings("brazillian_replacement.json", "brazillian")
		if("Infernal accent")
			return strings("spanish_replacement.json", "spanish")
		if("Greenskin accent")
			return strings("middlespeak.json", "middle")
		if("Pirate Accent")
			return strings("pirate_replacement.json", "full")
		if("Valley Girl accent")
			return strings("valley_replacement.json", type)
		if("Urban Orc accent")
			return strings("norf_replacement.json", type)
		if("Hissy accent")
			return strings("hissy_replacement.json", type)
		if("Inzectoid accent")
			return strings("inzectoid_replacement.json", type)
		if("Feline accent")
			return strings("feline_replacement.json", type)
		if("Slopes accent")
			return strings("welsh_replacement.json", type)

/datum/species/proc/get_accent(mob/living/carbon/human/H)
	return get_accent_list(H,"full")

/datum/species/proc/get_accent_any(mob/living/carbon/human/H) //determines if accent replaces in-word text
	return get_accent_list(H,"syllable")

/datum/species/proc/get_accent_start(mob/living/carbon/human/H)
	return get_accent_list(H,"start")

/datum/species/proc/get_accent_end(mob/living/carbon/human/H)
	return get_accent_list(H,"end")

#define REGEX_FULLWORD 1
#define REGEX_STARTWORD 2
#define REGEX_ENDWORD 3
#define REGEX_ANY 4

/datum/species/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]

	message = treat_message_accent(message, strings("accent_universal.json", "universal"), REGEX_FULLWORD)

	message = treat_message_accent(message, get_accent(source), REGEX_FULLWORD)
	message = treat_message_accent(message, get_accent_start(source), REGEX_STARTWORD)
	message = treat_message_accent(message, get_accent_end(source), REGEX_ENDWORD)
	message = treat_message_accent(message, get_accent_any(source), REGEX_ANY)

	speech_args[SPEECH_MESSAGE] = trim(message)


/proc/treat_message_accent(message, list/accent_list, chosen_regex)
	if(!message)
		return
	if(!accent_list)
		return message
	if(message[1] == "*")
		return message
	message = "[message]"
	for(var/key in accent_list)
		var/value = accent_list[key]
		if(islist(value))
			value = pick(value)

		switch(chosen_regex)
			if(REGEX_FULLWORD)
				// Full word regex (full world replacements)
				message = replacetextEx(message, regex("\\b[uppertext(key)]\\b|\\A[uppertext(key)]\\b|\\b[uppertext(key)]\\Z|\\A[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]\\b|\\A[capitalize(key)]\\b|\\b[capitalize(key)]\\Z|\\A[capitalize(key)]\\Z", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]\\b|\\A[key]\\b|\\b[key]\\Z|\\A[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_STARTWORD)
				// Start word regex (Some words that get different endings)
				message = replacetextEx(message, regex("\\b[uppertext(key)]|\\A[uppertext(key)]", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]|\\A[capitalize(key)]", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]|\\A[key]", "(\\w+)/g"), value)
			if(REGEX_ENDWORD)
				// End of word regex (Replaces last letters of words)
				message = replacetextEx(message, regex("[uppertext(key)]\\b|[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("[key]\\b|[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_ANY)
				// Any regex (syllables)
				// Careful about use of syllables as they will continually reapply to themselves, potentially canceling each other out
				message = replacetextEx(message, uppertext(key), uppertext(value))
				message = replacetextEx(message, key, value)

	return message

#undef REGEX_FULLWORD
#undef REGEX_STARTWORD
#undef REGEX_ENDWORD
#undef REGEX_ANY
