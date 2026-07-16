import 'package:flutter/material.dart';
import "../subpages/readbook.dart";

class Books extends StatelessWidget {
  final List<Map<String, String>> booksZ = [
    {
      "title": "Mindful Momentum",
      "summary":
          "A practical guide to building mental resilience and daily habits for emotional well-being.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80",
      "link": "https://sleepypanda.vercel.app",
    },
    {
      "title": "Stronger Every Morning",
      "summary":
          "Short routines and mindset shifts for fitness growth and sustainable energy.",
      "category": "fitness",
      "image":
          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/stronger-every-morning",
    },
    {
      "title": "Financial Freedom Fundamentals",
      "summary":
          "A clear starter plan to save, invest, and build independence from paycheck stress.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/financial-freedom-fundamentals",
    },
    {
      "title": "Quiet Strength",
      "summary":
          "A gentle self-improvement book on balancing ambition with calm and confidence.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/quiet-strength",
    },
    {
      "title": "Reset & Rebuild",
      "summary":
          "Fast mental health practices for resetting anxiety and creating a stronger daily routine.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/reset-and-rebuild",
    },
    {
      "title": "Fit Focus",
      "summary":
          "Combines fitness habits with mindfulness to help you stay active and mentally sharp.",
      "category": "fitness",
      "image":
          "https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/fit-focus",
    },
    {
      "title": "Smart Money Mindset",
      "summary":
          "A short guide to shifting how you think about money, savings, and long-term stability.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1495121605193-b116b5b9c5d5?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/smart-money-mindset",
    },
    {
      "title": "Rise With Routine",
      "summary":
          "Small daily changes for better sleep, energy, and a stronger mental outlook.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/rise-with-routine",
    },
    {
      "title": "Balance & Build",
      "summary":
          "A concise playbook for combining emotional wellness with disciplined personal growth.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/balance-and-build",
    },
    {
      "title": "Freedom Formula",
      "summary":
          "Simple steps for increasing income, reducing debt, and building long-term financial options.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1472437774355-71ab6752b434?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/freedom-formula",
    },
    {
      "title": "Intentional Living",
      "summary":
          "A quick guide to designing your day around purpose, productivity, and peace.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/intentional-living",
    },
    {
      "title": "Calm Confidence",
      "summary":
          "A short book on building self-esteem through mindful choices and honest self-talk.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/calm-confidence",
    },
    {
      "title": "Budget Better",
      "summary":
          "Seven practical steps to track spending, save more, and plan for financial independence.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/budget-better",
    },
    {
      "title": "Momentum Mindset",
      "summary":
          "A fast-start guide for turning small wins into sustainable self-improvement progress.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/momentum-mindset",
    },
    {
      "title": "Recovery Reset",
      "summary":
          "A brief workbook-style book for managing stress and rebuilding mental balance.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1529253355930-5f96bec1ea1d?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/recovery-reset",
    },
    {
      "title": "Wealth Habits",
      "summary":
          "A short collection of habits used by financially independent people.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1486401899868-0e435ed8512f?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/wealth-habits",
    },
    {
      "title": "Daily Discipline",
      "summary":
          "A compact routine to build discipline in health, work, and self-care.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1490665825128-ff5df9f5a1d1?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/daily-discipline",
    },
    {
      "title": "Mind Reset",
      "summary":
          "An easy-to-follow plan to reduce overthinking and strengthen emotional resilience.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/mind-reset",
    },
    {
      "title": "Invest In You",
      "summary":
          "A quick primer on making smarter money choices to grow future independence.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/invest-in-you",
    },
    {
      "title": "Stronger Mind, Stronger Body",
      "summary":
          "Short lessons that pair physical workouts with mental wellness practices.",
      "category": "fitness",
      "image":
          "https://images.unsplash.com/photo-1554284126-3c5c7f2f43cc?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/stronger-mind-stronger-body",
    },
    {
      "title": "Healthy Confidence",
      "summary":
          "A short book on building self-belief through small, consistent self-care choices.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/healthy-confidence",
    },
    {
      "title": "Peaceful Focus",
      "summary":
          "Guided exercises for reducing anxiety and improving concentration.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/peaceful-focus",
    },
    {
      "title": "Savings Sprint",
      "summary":
          "A concise roadmap to save faster and feel more secure with money.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1481833761820-0509d3217039?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/savings-sprint",
    },
    {
      "title": "Move With Purpose",
      "summary":
          "A short fitness plan to make daily movement feel energizing, not exhausting.",
      "category": "fitness",
      "image":
          "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/move-with-purpose",
    },
    {
      "title": "Positive Money Mindset",
      "summary":
          "A short guide for shifting financial fear into confidence and control.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1488998427799-e3362cec87c3?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/positive-money-mindset",
    },
    {
      "title": "Simple Strength",
      "summary":
          "A brief training plan for beginners who want fitness and more energy.",
      "category": "fitness",
      "image":
          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/simple-strength",
    },
    {
      "title": "Calm Commitment",
      "summary":
          "A short self-improvement guide for staying committed to calm, healthy habits.",
      "category": "self improvement",
      "image":
          "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/calm-commitment",
    },
    {
      "title": "Thrive Toolkit",
      "summary":
          "A quick-start collection of mental health tools for everyday resilience.",
      "category": "mental health",
      "image":
          "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/thrive-toolkit",
    },
    {
      "title": "Budget & Build",
      "summary":
          "A fast and friendly budgeting book for building wealth without stress.",
      "category": "financial independence",
      "image":
          "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80",
      "link": "https://example.com/budget-and-build",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: booksZ.length,
      itemBuilder: (context, index) {
        final book = booksZ[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Rbooks(book: book)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(118, 16, 42, 80),
                width: 3,
              ),
              color: const Color.fromARGB(255, 201, 203, 204),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: book['image'] != null && book['image']!.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(book['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(137, 0, 0, 0),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book['category']?.toUpperCase() ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                      Divider(height: 1, color: Colors.black54),
                      const SizedBox(height: 8),
                      Text(
                        book['summary'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
