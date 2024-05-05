import React from "react";

import LocaleLinks from "./LocaleLinks";

interface PageDescriptionProps {
  state: PageForm.State;
  dispatch: (action: PageForm.Action) => void;
  children: React.ReactNode;
}

function editLink(locale: string, page: Page.Ancestor | Page.Resource) {
  return (
    <a href={`/admin/${locale}/pages/${page.id}/edit`}>
      {pageName(locale, page)}
    </a>
  );
}

function pageName(locale: string, page: Page.Ancestor | Page.Resource) {
  if ("name" in page) {
    return page.name[locale];
  }
  return page.blocks.name[locale] || <i>Untitled</i>;
}

export default function PageDescription(props: PageDescriptionProps) {
  const { state, dispatch, children } = props;
  const { locale, page } = state;

  return (
    <div className="page-description with_content_tabs">
      <LocaleLinks state={state} dispatch={dispatch} />
      <h3>
        {page.ancestors.map((p) => (
          <React.Fragment key={p.id}>
            {editLink(locale, p)}
            {" » "}
          </React.Fragment>
        ))}
        {page.id ? editLink(locale, page) : "New Page"}
      </h3>
      {children}
    </div>
  );
}
