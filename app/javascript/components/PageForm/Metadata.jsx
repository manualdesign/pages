import React from "react";
import PropTypes from "prop-types";

import usePage, { blockValue, errorsOn } from "./usePage";
import Block from "./Block";
import PathSegment from "./PathSegment";
import LabelledField from "../LabelledField";
import ImageUploader from "../ImageUploader";

export default function Metadata(props) {
  const [state, dispatch] = usePage({
    locales: props.locales,
    locale: props.locale,
    page: props.page,
    templates: props.templates
  });

  const { page, locale, locales, inputDir, templateConfig } = state;

  const handleChange = (attr) => (value) => {
    dispatch({ type: "update", payload: { [attr]: value } });
  };

  return (
    <React.Fragment>
      <PathSegment state={state}
                   dispatch={dispatch} />
      <LabelledField
        htmlFor="page_meta_image_id"
        label="Image"
        description={"Image displayed when sharing on social media. " +
                     "Will fall back to the primary image if absent. " +
                     "Recommended size is at least 1200x630."}
        errors={errorsOn(page, "meta_image_id")}>
        <ImageUploader attr="page[meta_image_id]"
                       locale={locale}
                       locales={locales}
                       image={page.meta_image.image}
                       src={page.meta_image.src}
                       width={250}
                       caption={false} />
      </LabelledField>
      {templateConfig.metadata_blocks.map(b =>
        <Block key={b.name}
               block={b}
               errors={errorsOn(page, b.name)}
               dir={inputDir}
               lang={locale}
               onChange={handleChange(b.name)}
               value={blockValue(state, b)} />)}
    </React.Fragment>
  );
}

Metadata.propTypes = {
  locale: PropTypes.string,
  locales: PropTypes.object,
  page: PropTypes.object,
  templates: PropTypes.array
};
