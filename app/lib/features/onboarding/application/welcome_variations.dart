import 'dart:math';
import 'package:flutter/material.dart';

class FeatureItemData {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class WelcomeScreenVariation {
  final String variationId;
  final String category;
  final String title;
  final List<FeatureItemData> features;

  const WelcomeScreenVariation({
    required this.variationId,
    required this.category,
    required this.title,
    required this.features,
  });
}

final List<WelcomeScreenVariation> _welcomeScreenVariations = [
  // Variation 1: The "Anti-Habit-Hacker"
  const WelcomeScreenVariation(
    variationId: "anti_habit_hacker",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.link_off,
        title: "Stop Tracking. Start Proving.",
        subtitle:
            "You've tried trackers, journals, and hacks. They are lies that help you feel busy. It's time to do the one thing that works.",
      ),
      FeatureItemData(
        icon: Icons.flag_outlined,
        title: "Put Your Word on the Line.",
        subtitle:
            "Declare one daily commitment to the world. Not in a private app, but in a public arena where your word has weight.",
      ),
      FeatureItemData(
        icon: Icons.shield_outlined,
        title: "Become Undeniable.",
        subtitle:
            "When you succeed, it's not a checkmark. It's public proof. Build a reputation so strong that your own excuses can't touch it.",
      ),
    ],
  ),
  // Variation 2: The "Reputation is the New Currency"
  const WelcomeScreenVariation(
    variationId: "reputation_currency",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.monetization_on_outlined,
        title: "Make a Public Deposit.",
        subtitle:
            "Your daily promise isn't a task; it's an investment in your most valuable asset: your reputation.",
      ),
      FeatureItemData(
        icon: Icons.trending_up,
        title: "The Market Watches.",
        subtitle:
            "Your community votes, speculating on your integrity. Their expectation is the force that guarantees your execution.",
      ),
      FeatureItemData(
        icon: Icons.leaderboard_outlined,
        title: "Build Your Social Capital.",
        subtitle:
            "Every completed vote is a dividend paid in respect and trust. Become the person everyone knows they can bet on.",
      ),
    ],
  ),
  // Variation 3: The "Public Arena"
  const WelcomeScreenVariation(
    variationId: "public_arena",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.stadium_outlined,
        title: "Enter the Arena.",
        subtitle:
            "Forget quiet self-improvement. Your daily habit is now a public spectacle. Make your vow.",
      ),
      FeatureItemData(
        icon: Icons.visibility_outlined,
        title: "The Crowd Forms its Judgment.",
        subtitle:
            "They will vote. They will watch. Their collective gaze is the most powerful motivator on Earth. You can't hide.",
      ),
      FeatureItemData(
        icon: Icons.emoji_events_outlined,
        title: "Leave with Your Honor.",
        subtitle:
            "Fulfill your vow and earn their respect. Fail, and face the silent judgment of the crowd. The choice is yours, every single day.",
      ),
    ],
  ),
  // Variation 4: The "Brutal Honesty"
  const WelcomeScreenVariation(
    variationId: "brutal_honesty",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.error_outline,
        title: "Your Excuses Stop Here.",
        subtitle:
            "Let's be honest. You're good at starting and better at quitting. HabitVote is the system you can't lie to.",
      ),
      FeatureItemData(
        icon: Icons.lightbulb_outline,
        title: "Expose Your Goal to the Light.",
        subtitle:
            "Make your commitment. Your friends won't just see it; they will vote on their belief in you. Feel that? That's real accountability.",
      ),
      FeatureItemData(
        icon: Icons.shield_outlined,
        title: "Forge a New Reality.",
        subtitle:
            "Every day you succeed, you don't just check a box. You silence the liar in your head with cold, hard, public proof.",
      ),
    ],
  ),
  // Variation 5: The "Simple Contract"
  const WelcomeScreenVariation(
    variationId: "simple_contract",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.edit_document,
        title: "Sign the Daily Contract.",
        subtitle:
            "Choose one habit. By stating it here, you are entering into a binding social contract.",
      ),
      FeatureItemData(
        icon: Icons.handshake_outlined,
        title: "The Community is Your Witness.",
        subtitle:
            "They will vote to acknowledge the contract. They now have a stake in your outcome. Don't let them down.",
      ),
      FeatureItemData(
        icon: Icons.verified_outlined,
        title: "Your Word Becomes Bond.",
        subtitle:
            "Fulfilling the contract isn't about a streak; it's about integrity. This is how you build a reputation for being a person who delivers.",
      ),
    ],
  ),
  // Variation 6: The "Conspiracy of One"
  const WelcomeScreenVariation(
    variationId: "conspiracy_of_one",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.person_pin_circle_outlined,
        title: "Make the One-Man Stand.",
        subtitle:
            "Announce your daily mission. This is your personal battle, but the audience is public.",
      ),
      FeatureItemData(
        icon: Icons.how_to_vote_outlined,
        title: "Let Them Place Their Bets.",
        subtitle:
            "They will vote on you. Do they believe you have it in you? Or are they expecting you to fail? Their votes set the stage.",
      ),
      FeatureItemData(
        icon: Icons.help_outline,
        title: "End the Question.",
        subtitle:
            "Whether you prove the believers right or the doubters wrong, you win. Obliterate all speculation with the raw evidence of your action.",
      ),
    ],
  ),
  // Variation 7: The "Chain of Proof"
  const WelcomeScreenVariation(
    variationId: "chain_of_proof",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.link,
        title: "Forge the First Link.",
        subtitle:
            "Your promise today is the first link in a chain of evidence that proves who you are.",
      ),
      FeatureItemData(
        icon: Icons.manage_search_outlined,
        title: "The World Will Inspect It.",
        subtitle:
            "The vote isn't a guess; it's an inspection. The community holds your chain to the light to see if it's real.",
      ),
      FeatureItemData(
        icon: Icons.all_inclusive,
        title: "Build an Unbreakable History.",
        subtitle:
            "Each day, add another link. Soon, you won't have a \"streak.\" You'll have an undeniable history of your own reliability.",
      ),
    ],
  ),
  // Variation 8: The "Neurological Hack"
  const WelcomeScreenVariation(
    variationId: "neurological_hack",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.psychology_outlined,
        title: "Outsource Your Willpower.",
        subtitle:
            "Your internal discipline is finite and unreliable. Stop trying to \"feel\" motivated. It's a losing battle.",
      ),
      FeatureItemData(
        icon: Icons.hub_outlined,
        title: "Plug Into the Social Cortex.",
        subtitle:
            "By making a public vow, you activate the most powerful part of your brain: the part that craves social validation and fears social rejection.",
      ),
      FeatureItemData(
        icon: Icons.settings_suggest_outlined,
        title: "Automate Your Execution.",
        subtitle:
            "The daily vote isn't a feature; it's a trigger. It makes not doing the habit more painful than doing it. This is the only \"hack\" that works.",
      ),
    ],
  ),
  // Variation 9: The "Ignition Switch"
  const WelcomeScreenVariation(
    variationId: "ignition_switch",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.highlight_off, // Represents an unlit match
        title: "Provide the Fuel.",
        subtitle:
            "You have the potential. What you lack is the spark. Your one daily commitment is the fuel.",
      ),
      FeatureItemData(
        icon: Icons.whatshot_outlined,
        title: "The Vote is the Ignition.",
        subtitle:
            "The moment your community votes, the pressure builds. It's the friction required to create a fire where there was only cold wood.",
      ),
      FeatureItemData(
        icon: Icons.local_fire_department_outlined,
        title: "Let It Burn.",
        subtitle:
            "Use that fire to power your day. This isn't about tracking embers; it's about harnessing a self-sustaining blaze of momentum.",
      ),
    ],
  ),
  // Variation 10: The "Final Boss"
  const WelcomeScreenVariation(
    variationId: "final_boss",
    category: "general-brutal",
    title: "Welcome to HabitVote",
    features: [
      FeatureItemData(
        icon: Icons.sports_esports_outlined,
        title: "Choose Your Opponent.",
        subtitle:
            "The opponent is the version of you that quits. Name the one habit that will defeat him today.",
      ),
      FeatureItemData(
        icon: Icons.health_and_safety_outlined,
        title: "Your Friends Set the Difficulty.",
        subtitle:
            "Their votes are a power-up. The more who believe in you, the more damage you do to your own apathy.",
      ),
      FeatureItemData(
        icon: Icons.workspace_premium_outlined,
        title: "Defeat Yourself. Daily.",
        subtitle:
            "This is the game you can't afford to lose. Every win isn't for points; it's to prove, publicly, who is in control of your life.",
      ),
    ],
  ),
];

/// A global variable that holds the randomly chosen variation for the welcome screen.
/// This is initialized once and will not change during the app's lifecycle.
final WelcomeScreenVariation chosenWelcomeVariation =
    _welcomeScreenVariations[Random().nextInt(_welcomeScreenVariations.length)];
