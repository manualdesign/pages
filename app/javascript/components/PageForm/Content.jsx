import React from "react";
import PropTypes from "prop-types";

import usePage, { blockValue, errorsOn } from "./usePage";
import LabelledField from "../LabelledField";
import TagEditor from "../TagEditor";
import Block from "./Block";
import Dates from "./Dates";

export default function Content(props) {
  const [state, dispatch] = usePage({
    locales: props.locales,
    locale: props.locale,
    page: props.page,
    templates: props.templates
  });

  const { page, locale, inputDir, templateConfig } = state;

  const handleChange = (attr) => (value) => {
    dispatch({ type: "update", payload: { [attr]: value } });
  };

  return (
    <React.Fragment>
      {templateConfig.blocks.map(b =>
        <Block key={b.name}
               block={b}
               errors={errorsOn(page, b.name)}
               dir={inputDir}
               lang={locale}
               onChange={handleChange(b.name)}
               value={blockValue(state, b)} />)}
      {templateConfig.dates &&
       <Dates starts_at={page.starts_at}
              ends_at={page.ends_at}
              all_day={page.all_day} />}
      {templateConfig.tags &&
       <LabelledField label="Tags">
         <TagEditor name="page[serialized_tags]"
                    enabled={page.enabled_tags}
                    tags={page.tags_and_suggestions} />
       </LabelledField>}
    </React.Fragment>
  );
}

Content.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array
};
