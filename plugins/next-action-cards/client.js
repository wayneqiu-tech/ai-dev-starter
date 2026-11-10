window.__ModuleLoader__.load({
  id: '@local/next-action-cards',
  factory(require) {
    const React = require('react');
    const h = React.createElement;
    const ACTION = 'next_action';

    function Body(props) {
      const { summary, act, t } = props;
      const label = props.proposal?.details?.label || t('continue');
      const url = props.proposal?.details?.url;
      const href = typeof url === 'string' && /^https?:\/\//i.test(url) ? url : undefined;
      const style = {
        display: 'inline-block',
        marginRight: 8,
        padding: '6px 12px',
        borderRadius: 6,
        border: '1px solid var(--dsw-alias-border, #d0d7de)',
        background: 'var(--dsw-alias-bg, #fff)',
        color: 'var(--dsw-alias-text, #111)',
        cursor: 'pointer',
        textDecoration: 'none',
      };
      const action = href
        ? h(
            'a',
            {
              href,
              target: '_blank',
              rel: 'noopener noreferrer',
              onClick: () => act('accept'),
              style,
            },
            label,
          )
        : h(
            'button',
            {
              type: 'button',
              onClick: () => act('accept'),
              style: { ...style, font: 'inherit' },
            },
            label,
          );
      return h(
        'div',
        { style: { padding: '10px 0' } },
        h('div', { style: { marginBottom: 8 } }, summary),
        h('div', null, action, h(
          'button',
          {
            type: 'button',
            onClick: () => act('stop'),
            style: { ...style, font: 'inherit' },
          },
          t('stop'),
        )),
      );
    }

    return {
      inject: ['locale', 'actionCards'],
      apply(ctx) {
        ctx.effect(
          () =>
            ctx.locale.register('nextAction', {
              en: { continue: 'Continue', stop: 'Stop' },
              zh: { continue: '继续', stop: '停止' },
            }),
          'next-action-cards: locale',
        );
        ctx.effect(
          () =>
            ctx.actionCards.register({
              action: ACTION,
              locale: 'nextAction',
              Body,
            }),
          'next-action-cards: body',
        );
      },
    };
  },
});
