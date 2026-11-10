/**
 * Host half of the Next Action Gate card.
 * Registers a card kind and a small skill; the Client half owns the buttons.
 */
const ACTION = 'next_action';
const SKILL = 'next-action';

const details = {
  safeParse(input) {
    if (input === null || typeof input !== 'object') {
      return { success: false, error: { issues: [{ path: [], message: 'details must be an object' }] } };
    }
    const label = typeof input.label === 'string' ? input.label.trim() : '';
    if (!label) {
      return { success: false, error: { issues: [{ path: ['label'], message: 'label is required' }] } };
    }
    const data = { label };
    for (const key of ['url', 'command', 'reason']) {
      if (typeof input[key] === 'string' && input[key].trim()) data[key] = input[key].trim();
    }
    return { success: true, data };
  },
};

const skillContent = `# Next Action Gate

Use this skill at the end of a task, after you have verified the result.

Call \`propose_action\` exactly once with:

- \`action\`: \`next_action\`
- \`title\`: a short action title (for example "Open pull request")
- \`brief\`: one sentence explaining what the user is approving
- \`details\`: \`{ "label": "<button label>", "url": "<optional URL>", "command": "<optional command>" }\`

Then stop. Do not restate the card; the card appears below the answer.
One card per turn. Never bundle merge, deploy and cleanup into one card.
`;

export const name = 'next-action-cards';
export const inject = ['skills', 'actionCards', 'systemPrompt'];

export function apply(ctx) {
  ctx.effect(
    () =>
      ctx.systemPrompt.section({
        name: 'ai-dev:next-action',
        order: 500,
        text: `AI Dev Standard: end every completed task with exactly one Next Action Gate.
If the next-action skill is available, load it and call propose_action with action "next_action",
a short title, a brief, and details { label, url? }. One primary action plus stop.
Never end with "if you want, I can..." prose. If action cards are unavailable, use ask_user_question.`,
      }),
    'next-action-cards: system prompt',
  );

  const candidate = {
    name: SKILL,
    description: 'Offer one executable next action as a clickable card at the end of a task.',
    provider: 'ai-dev-next-action',
    source: 'bundled',
    rank: 100,
    locator: null,
    invocation: { modelInvocable: true, userInvocable: true },
  };

  ctx.effect(
    () =>
      ctx.skills.registerProvider(() => ({
        name: candidate.provider,
        list: () => Promise.resolve([candidate]),
        async get() {
          const { rank: _rank, locator: _locator, ...summary } = candidate;
          return { ...summary, content: skillContent };
        },
      })),
    'next-action-cards: skill',
  );

  ctx.actionCards.register({
    action: ACTION,
    skill: SKILL,
    details,
    invitation:
      'End with one short invitation in the user’s language: click the button below to continue, or stop.',
    verbs: {
      accept: {},
      stop: {},
    },
    openPhases: ['accepted', 'stopped'],
    async act(agent, proposal, verb) {
      const phase = verb === 'stop' ? 'stopped' : 'accepted';
      const decision = {
        callId: proposal.callId,
        action: ACTION,
        phase,
        data: proposal.details,
      };
      ctx.actionCards.record(agent, decision);
      return { status: 'settled', decision };
    },
  });
}
