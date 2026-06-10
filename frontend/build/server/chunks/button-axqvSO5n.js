import { ai as attributes, aj as clsx$1, ak as bind_props } from './dev-DBdtSqNh.js';
import { d as cn } from './card-D-P3c-kH.js';
import { t as tv } from './index-jeR0PSLo.js';

//#region src/lib/components/ui/button/button.svelte
var buttonVariants = tv({
	base: "focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:aria-invalid:border-destructive/50 rounded-4xl border border-transparent bg-clip-padding text-sm font-medium focus-visible:ring-[3px] active:not-aria-[haspopup]:translate-y-px aria-invalid:ring-[3px] [&_svg:not([class*='size-'])]:size-4 group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0",
	variants: {
		variant: {
			default: "bg-primary text-primary-foreground hover:bg-primary/80",
			outline: "border-border bg-input/30 hover:bg-input/50 hover:text-foreground aria-expanded:bg-muted aria-expanded:text-foreground",
			secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80 aria-expanded:bg-secondary aria-expanded:text-secondary-foreground",
			ghost: "hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 aria-expanded:bg-muted aria-expanded:text-foreground",
			destructive: "bg-destructive/10 hover:bg-destructive/20 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/20 text-destructive focus-visible:border-destructive/40 dark:hover:bg-destructive/30",
			link: "text-primary underline-offset-4 hover:underline"
		},
		size: {
			default: "h-9 gap-1.5 px-3 has-data-[icon=inline-end]:pr-2.5 has-data-[icon=inline-start]:pl-2.5",
			xs: "h-6 gap-1 px-2.5 text-xs has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2 [&_svg:not([class*='size-'])]:size-3",
			sm: "h-8 gap-1 px-3 has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2",
			lg: "h-10 gap-1.5 px-4 has-data-[icon=inline-end]:pr-3 has-data-[icon=inline-start]:pl-3",
			icon: "size-9",
			"icon-xs": "size-6 [&_svg:not([class*='size-'])]:size-3",
			"icon-sm": "size-8",
			"icon-lg": "size-10"
		}
	},
	defaultVariants: {
		variant: "default",
		size: "default"
	}
});
function Button($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { class: className, variant = "default", size = "default", ref = null, href = void 0, type = "button", disabled, children, $$slots, $$events, ...restProps } = $$props;
		if (href) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<a${attributes({
				"data-slot": "button",
				class: clsx$1(cn(buttonVariants({
					variant,
					size
				}), className)),
				href: disabled ? void 0 : href,
				"aria-disabled": disabled,
				role: disabled ? "link" : void 0,
				tabindex: disabled ? -1 : void 0,
				...restProps
			})}>`);
			children?.($$renderer);
			$$renderer.push(`<!----></a>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<button${attributes({
				"data-slot": "button",
				class: clsx$1(cn(buttonVariants({
					variant,
					size
				}), className)),
				type,
				disabled,
				...restProps
			})}>`);
			children?.($$renderer);
			$$renderer.push(`<!----></button>`);
		}
		$$renderer.push(`<!--]-->`);
		bind_props($$props, { ref });
	});
}

export { Button as B };
//# sourceMappingURL=button-axqvSO5n.js.map
