window.__ModuleLoader__.load({
  id: '@local/next-action-cards',
  factory(require) {
    const React = require('react');
    const h = React.createElement;
    const ACTION = 'next_action';

    function Body(props) {
      const { summary, act, t, decision } = props;
      const [notice, setNotice] = React.useState('');
      const [pending, setPending] = React.useState(false);
      const label = props.proposal?.details?.label || t('continue');
      const url = props.proposal?.details?.url;
      const title = props.proposal?.details?.title;
      const body = props.proposal?.details?.body;
      const withPrefill = (raw) => {
        try {
          const parsed = new URL(raw);
          if (parsed.hostname === 'github.com' && /\/releases\/new\/?$/.test(parsed.pathname)) {
            if (typeof title === 'string' && title) parsed.searchParams.set('title', title);
            if (typeof body === 'string' && body) parsed.searchParams.set('body', body);
          }
          return parsed.toString();
        } catch {
          return raw;
        }
      };
      const href = typeof url === 'string' && /^https?:\/\//i.test(url) ? withPrefill(url) : undefined;
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
      const submit = async (verb) => {
        setPending(true);
        setNotice(t('sending'));
        try {
          const result = await act(verb);
          setNotice(result?.status ? `${t('submitted')}: ${result.status}` : t('submitted'));
        } catch (error) {
          setNotice(`${t('failed')}: ${String(error?.message || error)}`);
        } finally {
          setPending(false);
        }
      };
      const action = href
        ? h(
            'a',
            {
              href,
              target: '_blank',
              rel: 'noopener noreferrer',
              onClick: () => {
                if (typeof body === 'string' && body && navigator.clipboard?.writeText) {
                  navigator.clipboard.writeText(body).catch(() => {});
                }
                submit('accept');
              },
              style,
            },
            label,
          )
        : h(
            'button',
            {
              type: 'button',
              disabled: pending,
              onClick: () => submit('accept'),
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
            onClick: () => submit('stop'),
            disabled: pending,
            style: { ...style, font: 'inherit' },
          },
          t('stop'),
        )),
        notice
          ? h('div', { style: { marginTop: 8, fontSize: 12, opacity: 0.8 } }, notice)
          : decision?.phase
            ? h('div', { style: { marginTop: 8, fontSize: 12, opacity: 0.8 } }, `${t('phase')}: ${decision.phase}`)
            : null,
      );
    }

    return {
      inject: ['locale', 'actionCards'],
      apply(ctx) {
        ctx.effect(
          () =>
            ctx.locale.register('nextAction', {
              en: { continue: 'Continue', stop: 'Stop', sending: 'Submitting…', submitted: 'Submitted', failed: 'Submit failed', phase: 'Status' },
              zh: { continue: '继续', stop: '停止', sending: '正在提交…', submitted: '已提交', failed: '提交失败', phase: '状态' },
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
